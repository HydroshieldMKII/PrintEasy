# frozen_string_literal: true

class Request < ApplicationRecord
  belongs_to :user
  has_many :offers, dependent: :destroy
  has_many :preset_requests, dependent: :destroy

  # after_update :after_update
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
  validate :can_update?, on: :update

  before_destroy :can_destroy?, prepend: true

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
  scope :by_budget_range, lambda { |min_budget, max_budget|
    where('requests.budget >= ? AND requests.budget <= ?', min_budget, max_budget) if min_budget.present? && max_budget.present?
  }

  scope :by_date_range, lambda { |start_date, end_date|
    if start_date.present? && end_date.present?
      where('requests.target_date >= ? AND requests.target_date <= ?',
            start_date.to_date.beginning_of_day,
            end_date.to_date.end_of_day)
    elsif start_date.present?
      where('requests.target_date >= ?', start_date.to_date.beginning_of_day)
    end
  }

  scope :sorted, lambda { |category, direction|
    return order('target_date ASC') unless category.present? && direction.present?

    column = {
      'name' => 'requests.name',
      'date' => 'target_date',
      'budget' => 'budget',
      'country' => 'users.country_id'
    }.fetch(category, 'target_date')

    direction = direction == 'asc' ? 'ASC' : 'DESC'
    order("#{column} #{direction}")
  }

  scope :viewable_by_user, lambda {
    where(user: Current.user).or(
      Current.user.printers.exists? ? where.not(id: nil) : []
    )
  }

  def self.fetch_for_user(params)
    requests = case params[:type]
               when 'all'
                 if Current.user.printers.exists?
                   with_associations
                     .where.not(user: Current.user)
                     .not_accepted
                     .search_by_name(params[:search])
                 else
                   [] #user no printers
                 end
               when 'mine'
                 Current.user.requests
                        .with_associations
                        .search_by_name(params[:search])
               else
                  []
               end
    
    requests = case params[:filter]
               when 'owned-printer'
                 requests.by_printer_owner
               when 'country'
                 requests.by_country
               when 'in-progress'
                 requests.in_progress
               else
                 requests
               end
    
    requests = requests.sorted(params[:sortCategory], params[:sort])
               .by_budget_range(params[:minBudget], params[:maxBudget])
               .by_date_range(params[:startDate], params[:endDate])
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
          },
          methods: [:matching_offer_by_current_user?]
        },
        user: {
          only: %i[id username],
          include: {
            country: { only: %i[name] }
          }
        }
      },
      methods: %i[stl_file_url offer_made? accepted_at]
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
          },
          methods: [:matching_offer_by_current_user?]
        },
        user: {
          only: %i[id username],
          include: {
            country: { only: %i[name] }
          }
        }
      },
      methods: %i[stl_file_url offer_made? accepted_at]
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

  def offer_made?
    offers.exists?
  end

  def offer_accepted?
    offers.joins(:order).exists?
  end

  def accepted_at
    offers.joins(:order).first&.created_at
  end

  private

  def can_destroy?
    unless user == Current.user
      errors.add(:base, 'You are not allowed to delete this request')
      throw(:abort)
    end

    return unless offer_accepted?

    errors.add(:base, 'Cannot delete request with accepted offers')
    throw(:abort)
  end

  def can_update?
    unless user == Current.user
      errors.add(:request, 'You are not allowed to update this request')
      return false
    end
    return unless offer_accepted?

    errors.add(:base, 'Cannot update request with accepted offers')
    false
  end

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
