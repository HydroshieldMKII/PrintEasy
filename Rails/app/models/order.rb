# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :offer
  has_many :order_status
  accepts_nested_attributes_for :order_status
  has_one :request, through: :offer
  has_one :review

  validates :offer_id, presence: true, uniqueness: true
  validate :offer_exists
  validate :not_the_same_user_for_offer_and_request
  validate :not_two_order_with_the_same_request
  validate :user_owns_request

  scope :search_by_name, lambda { |query|
    joins(offer: :request).where('requests.name LIKE ? OR requests.comment LIKE ?', "%#{query}%", "%#{query}%") if query.present?
  }
  scope :status_filter, lambda { |status|
    joins(:order_status)
      .where(order_status: { id: OrderStatus.select('MAX(id)').group(:order_id) })
      # .where(order_status: { status_name: status })
      .where('order_status.status_name IN (?)', status)
  }
  scope :review_filter, -> { joins(:review) }
  scope :not_review_filter, -> { where.not(id: joins(:review).select(:id)) }
  scope :apply_sort, lambda { |sort|
    return order('offers.target_date DESC') unless sort.present?

    field, direction = sort.split('-')
    column = {
      'name' => 'requests.name',
      'date' => 'offers.target_date',
      'price' => 'offers.price'
    }.fetch(field, 'offers.target_date')
    direction = direction == 'asc' ? 'ASC' : 'DESC'
    joins(offer: :request).order("#{column} #{direction}")
  }

  def self.fetch_for_user(params)
    case params[:type]
    when 'printer'
      joins(offer: { printer_user: :user })
    else
      joins(offer: { request: :user })
    end
      .where(users: { id: Current.user.id })
      .search_by_name(params[:search])
      .apply_filters(params[:filter])
      .apply_sort(params[:sort])
  end

  def self.apply_filters(filter)
    filter = '' if filter.nil?
    filters = filter.split(';')
    result = all
    filters.each do |fil|
      if fil == 'reviewed'
        result = result.review_filter
      elsif fil == 'notReviewed'
        result = result.not_review_filter
      end
    end
    similar_status = %w[Accepted Printing Printed Shipped Arrived Cancelled].intersection(filters)
    result = result.status_filter(similar_status) if similar_status.length.positive?
    result
  end

  def self.fetch_report(params)
    column, direction = params[:sort].split('-') if params[:sort].present?
    column = {
      'time' => 'average_time_to_complete',
      'rating' => 'average_rating',
      'earnings' => 'money_earned'
    }.fetch(column, 'in_progress_orders')
    direction = direction == 'asc' ? 'ASC' : 'DESC'

    sanitized_date_filter = ''
    if params[:start_date].present? && !params[:end_date].present?
      sanitized_date_filter = ActiveRecord::Base.sanitize_sql_for_conditions(["WHERE created_at >= STR_TO_DATE( ? , '%Y-%m-%d')",
                                                                              params[:start_date]])
    elsif !params[:start_date].present? && params[:end_date].present?
      sanitized_date_filter = ActiveRecord::Base.sanitize_sql_for_conditions(["WHERE created_at <= STR_TO_DATE( ? , '%Y-%m-%d')",
                                                                              params[:end_date]])
    elsif params[:start_date].present? && params[:end_date].present?
      sanitized_date_filter = ActiveRecord::Base.sanitize_sql_for_conditions([
                                                                               "WHERE created_at >= STR_TO_DATE( ? , '%Y-%m-%d')
                                                                                AND created_at <= STR_TO_DATE( ? , '%Y-%m-%d')",
                                                                               params[:start_date],
                                                                               params[:end_date]
                                                                             ])
    end
    sql = <<-SQL
        WITH latest_order_status AS (
          SELECT
            order_id,
            MAX(created_at) AS latest_status_time
          FROM order_status #{sanitized_date_filter}
          GROUP BY order_id
        ),
        basic_order_info AS (
          SELECT
            printer_users.id AS printer_user_id,
            printer_users.printer_id AS printer_id,
            reviews.rating AS rating,
            offers.price AS price,
            orders.id AS order_id,
            order_status.status_name AS status_name,
            order_status.created_at AS created_at
          FROM orders
          LEFT JOIN offers ON orders.offer_id = offers.id
          LEFT JOIN printer_users ON offers.printer_user_id = printer_users.id
          LEFT JOIN order_status ON orders.id = order_status.order_id
          LEFT JOIN reviews ON orders.id = reviews.order_id
          JOIN latest_order_status ON orders.id = latest_order_status.order_id AND order_status.created_at = latest_order_status.latest_status_time
          WHERE printer_users.user_id = ?
          GROUP BY printer_users.id, orders.id
        )
        SELECT
          printers.model AS printer_model,
          SUM(basic_order_info.status_name = 'Arrived') AS completed_orders,
          SUM(basic_order_info.status_name = 'Cancelled') AS cancelled_orders,
          SUM(basic_order_info.status_name = 'Printing' OR basic_order_info.status_name = 'Printed' OR basic_order_info.status_name = 'Shipped' OR basic_order_info.status_name = 'Accepted') AS in_progress_orders,
          AVG(CASE WHEN (basic_order_info.status_name = 'Arrived') THEN basic_order_info.rating ELSE null END) AS average_rating,
          (CASE WHEN basic_order_info.status_name = 'Arrived' OR basic_order_info.status_name = 'Cancelled' THEN
            CAST(
              TRUNCATE(
                SEC_TO_TIME(
                  AVG(
                    TIMESTAMPDIFF(
                      SECOND,
                      (SELECT MIN(order_status.created_at) FROM order_status JOIN orders ON orders.id = order_status.order_id WHERE orders.id = latest_order_status.order_id),
                      latest_order_status.latest_status_time)
                    )
                  ),
                0
              )
              AS CHAR(10)
            )
           ELSE NULL END) AS average_time_to_complete,
          SUM(CASE WHEN (basic_order_info.status_name = 'Arrived') THEN basic_order_info.price ELSE null END) AS money_earned
        FROM printer_users
        JOIN printers ON printer_users.printer_id = printers.id
        LEFT JOIN basic_order_info ON printer_users.id = basic_order_info.printer_user_id
        LEFT JOIN latest_order_status ON basic_order_info.order_id = latest_order_status.order_id
        WHERE printer_users.user_id = ?
        GROUP BY printers.model
        ORDER BY #{column} #{direction}
    SQL
    ActiveRecord::Base.connection.select_all(
      ActiveRecord::Base.sanitize_sql_array(
        [sql, Current.user.id, Current.user.id]
      )
    ).to_a
  end

  def printer
    offer&.printer_user&.user
  end

  def consumer
    offer&.request&.user
  end

  def available_status
    order_status.last.available_status
  end

  private

  def offer_exists
    if offer.nil?
      errors.add(:offer_id, 'Offer must exist')
      return false
    end
    true
  end

  def not_the_same_user_for_offer_and_request
    if consumer == printer
      errors.add(:offer_id, 'Consumer and printer cannot be the same user')
      return false
    end
    true
  end

  def not_two_order_with_the_same_request
    return false if request.nil?
    return true unless request.offers.joins(:order).count.positive?

    errors.add(:offer_id, 'Request already has an order')
    false
  end

  def user_owns_request
    if consumer != Current.user
      errors.add(:offer_id, 'User is not owner of request')
      return false
    end
    true
  end
end
