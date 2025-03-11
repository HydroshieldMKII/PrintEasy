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
    if min_budget.present? && max_budget.present?
      where('requests.budget >= ? AND requests.budget <= ?', min_budget, max_budget)
    elsif min_budget.present?
      where('requests.budget >= ?', min_budget)
    elsif max_budget.present?
      where('requests.budget <= ?', max_budget)
    end
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
    return order('requests.target_date ASC') unless category.present? && direction.present?

    column = {
      'name' => 'requests.name',
      'date' => 'requests.target_date',
      'budget' => 'requests.budget',
      'country' => 'users.country_id'
    }.fetch(category, 'requests.target_date')

    direction = direction == 'asc' ? 'ASC' : 'DESC'
    order("#{column} #{direction}")
  }

  scope :viewable_by_user, lambda {
    where(user: Current.user).or(
      Current.user.printers.exists? ? where.not(id: nil) : []
    )
  }

  # Entity: Pesets + Preset in offers (Filament, Color, Quality combination)
  # Stats
  # Offer count with the preset (all)
  # Offer count with the preset (accepted)
  # Offer count with the preset (accepted, in percent)
  # Sum price of offers (accepted)
  # Average diff offer price vs request budget (all)
  # Average time to offer a preset on requests (since request published) (all)

  def self.fetch_stats_for_user
    sql = <<-SQL
      WITH user_preset_combinations AS (
        -- User preset
        SELECT
          p.color_id,
          p.filament_id,
          p.print_quality,
          p.id AS preset_id
        FROM
          presets p
        WHERE
          p.user_id = :user_id
         
        UNION
       
        -- User offer
        SELECT DISTINCT
          o.color_id,
          o.filament_id,
          o.print_quality,
          NULL AS preset_id
        FROM
          offers o
        JOIN
          printer_users pu ON o.printer_user_id = pu.id
        WHERE
          pu.user_id = :user_id
      ),
      preset_stats AS (
        SELECT
          upc.color_id,
          upc.filament_id,
          upc.print_quality,
          upc.preset_id,
          c.name AS color_name,
          f.name AS filament_name,
          COUNT(DISTINCT o.id) AS total_offers,
          SUM(CASE WHEN o.id IN (SELECT offer_id FROM orders) THEN 1 ELSE 0 END) AS accepted_offers,
          SUM(CASE WHEN o.id IN (SELECT offer_id FROM orders) THEN o.price ELSE 0 END) AS total_accepted_price,
          AVG(o.price - r.budget) AS avg_price_diff_from_budget,
          AVG(TIMESTAMPDIFF(HOUR, r.created_at, o.created_at)) AS avg_hours_to_offer
        FROM
          user_preset_combinations upc
          JOIN colors c ON upc.color_id = c.id
          JOIN filaments f ON upc.filament_id = f.id
          LEFT JOIN offers o ON
            o.color_id = upc.color_id AND
            o.filament_id = upc.filament_id AND
            o.print_quality = upc.print_quality AND
            o.printer_user_id IN (SELECT id FROM printer_users WHERE user_id = :user_id)
          LEFT JOIN requests r ON o.request_id = r.id
        GROUP BY
          upc.color_id, upc.filament_id, upc.print_quality, upc.preset_id, c.name, f.name
      )
      SELECT
        ps.preset_id,
        ps.print_quality AS preset_quality,
        ps.color_name,
        ps.filament_name,
        ps.total_offers,
        ps.accepted_offers,
        CAST(CASE
          WHEN ps.total_offers > 0 THEN ROUND((ps.accepted_offers * 100.0 / ps.total_offers), 2)
          ELSE 0
        END AS float) AS acceptance_rate_percent,
        ps.total_accepted_price,
        ROUND(ps.avg_price_diff_from_budget, 2) AS avg_price_diff,
        ROUND(ps.avg_hours_to_offer, 2) AS avg_response_time_hours
      FROM
        preset_stats ps
      ORDER BY
        ps.accepted_offers DESC,
        ps.total_offers DESC
    SQL
  
    sanitized_sql = ApplicationRecord.sanitize_sql_array([sql, user_id: Current.user.id])
    ActiveRecord::Base.connection.select_all(sanitized_sql).to_a
  end

  def self.fetch_for_user(params)
    requests = case params[:type]
           when 'all'
            if Current.user.printers.exists?
              self.with_associations
              .where.not(user: Current.user)
              .not_accepted
            else
              []
            end
           when 'mine'
              self.with_associations.where(user: Current.user)
            else
              []
           end
            
    requests = requests.search_by_name(params[:search]) if params[:search].present?    
    unless requests.empty?
      #filters
      filters = params[:filter].split(',') rescue []
      requests = requests.by_printer_owner if filters.include?('owned-printer')
      requests = requests.by_country if filters.include?('country')
      requests = requests.in_progress if filters.include?('in-progress')

      requests = requests.sorted(params[:sortCategory], params[:sort])
                .by_budget_range(params[:minBudget], params[:maxBudget])
                .by_date_range(params[:startDate], params[:endDate])
    else
      requests
    end
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
