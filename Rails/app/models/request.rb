# frozen_string_literal: true

class Request < ApplicationRecord
  belongs_to :user
  has_many :offers, dependent: :destroy
  has_many :preset_requests, dependent: :destroy
  validate :unique_preset_requests

  accepts_nested_attributes_for :preset_requests, allow_destroy: true
  validates :user_id, presence: true
  validates :name, presence: true, length: { in: 3..30 }
  validates :budget, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10_000 }
  validates :comment, length: { maximum: 200 }
  has_one_attached :stl_file

  # Create
  validates :stl_file, presence: true, on: :create
  validates :target_date, presence: true, comparison: { greater_than: Date.today }, on: :create

  # Update
  validate :target_date_cannot_be_in_the_past_on_update, on: :update
  validate :stl_file_must_have_stl_extension

  scope :with_associations, -> { includes(:user, preset_requests: %i[color filament printer]) }
  scope :search_by_name, lambda { |query|
    where('requests.name LIKE ?', "%#{query}%") if query.present?
  }
  scope :not_accepted, lambda {
    accepted_requests = joins(offers: { order: :order_status })
                        .where(order_status: { status_name: 'Accepted' })
    where.not(id: accepted_requests)
  }
  scope :by_printer_owner, lambda {
    joins(:preset_requests)
      .where(preset_requests: { printer: Current.user.printers })
      .distinct
  }
  scope :by_country, lambda {
    joins(:user).where(users: { country_id: Current.user.country_id }).distinct
  }
  scope :in_progress, lambda {
    joins(offers: { order: :order_status })
      .where(order_status: { status_name: 'Accepted' })
      .distinct
  }
  scope :sorted, lambda { |category, direction|
    return order('target_date ASC') unless category.present? && direction.present?

    column = {
      'name' => 'requests.name',
      'date' => 'target_date',
      'budget' => 'budget',
      'country' => 'users.country_id'
    }.fetch(category, 'date')

    direction = direction == 'asc' ? 'ASC' : 'DESC'
    order("#{column} #{direction}")
  }

  def self.fetch_for_user(params)
    case params[:type]
    when 'all'
      if Current.user.printers.exists?
        with_associations
          .where.not(user: Current.user)
          .not_accepted
          .search_by_name(params[:search])
          .apply_filter(params[:filter])
          .sorted(params[:sortCategory], params[:sort])
      else
        none
      end
    when 'mine'
      Current.user.requests
             .with_associations
             .search_by_name(params[:search])
             .apply_filter(params[:filter])
             .sorted(params[:sortCategory], params[:sort])
    else
      none
    end
  end

  def self.apply_filter(filter)
    case filter
    when 'owned-printer'
      by_printer_owner
    when 'country'
      by_country
    when 'in-progress'
      in_progress
    else
      all
    end
  end

  # Serialize a single request
  def serialize
    as_json(
      except: %i[user_id created_at updated_at],
      include: {
        preset_requests: {
          except: %i[request_id color_id filament_id printer_id],
          include: {
            color: { only: %i[id name] },
            filament: { only: %i[id name] },
            printer: { only: %i[id model] }
          }
        },
        user: {
          only: %i[id username],
          include: {
            country: { only: %i[name] }
          }
        }
      },
      methods: %i[stl_file_url has_offer_made? accepted_at]
    )
  end

  # Serialize a collection of requests
  def self.serialize_collection(requests)
    requests.as_json(
      except: %i[user_id created_at updated_at],
      include: {
        preset_requests: {
          except: %i[request_id color_id filament_id printer_id],
          include: {
            color: { only: %i[id name] },
            filament: { only: %i[id name] },
            printer: { only: %i[id model] }
          }
        },
        user: {
          only: %i[id username],
          include: {
            country: { only: %i[name] }
          }
        }
      },
      methods: %i[stl_file_url has_offer_made? accepted_at]
    )
  end

  def self.format_response(resource, status: :ok)
    has_printer = Current.user.printers.exists?

    request_data = if resource.is_a?(Request)
                     resource.serialize
                   else
                     serialize_collection(resource)
                   end

    {
      json: {
        request: request_data,
        has_printer: has_printer,
        errors: {}
      },
      status: status
    }
  end

  def stl_file_url
    Rails.application.routes.url_helpers.rails_blob_url(stl_file, only_path: true)
  end

  def has_offer_made?
    offers.exists?
  end

  def has_offer_accepted?
    offers.joins(:order).exists?
  end

  def accepted_at
    offers.joins(:order).first&.created_at
  end

  def update(_params)
    unless user == Current.user
      errors.add(:request, 'You are not allowed to update this request')
      return false
    end
    if has_offer_accepted?
      errors.add(:base, 'Cannot update request with accepted offers')
      return false
    end
    super
  end

  def destroy
    unless user == Current.user
      errors.add(:request, 'You are not allowed to delete this request')
      return false
    end
    if has_offer_accepted?
      errors.add(:request, 'Cannot delete request with accepted offers')
      return false
    end
    super
  end

  def viewable_by_user?
    Current.user == user || Current.user.printers.exists?
  end

  private

  def target_date_cannot_be_in_the_past_on_update
    return unless target_date_changed? && target_date < Date.today

    errors.add(:target_date, 'must be greater than today')
  end

  def stl_file_must_have_stl_extension
    return unless stl_file.attached?

    filename = stl_file.filename.to_s
    extension = File.extname(filename)
    return if extension.downcase == '.stl'

    errors.add(:stl_file, 'must have .stl extension')
  end

  def unique_preset_requests
    seen = {}
    preset_requests.each do |preset|
      key = [preset.color_id, preset.filament_id, preset.printer_id, preset.print_quality]
      if seen[key]
        errors.add(:base, 'Duplicate preset exists in the request')
      else
        seen[key] = true
      end
    end
  end
end
