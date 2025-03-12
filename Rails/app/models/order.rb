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

  scope :search_by_name, ->(query) { joins(offer: :request).where('requests.name LIKE ? OR requests.comment LIKE ?', "%#{query}%", "%#{query}%") if query.present? }
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
    filter = "" if filter.nil?
    filters = filter.split(';')
    result = all
    filters.each do |fil|
      if fil == 'reviewed'
        result = result.review_filter
      elsif fil == 'notReviewed'
        result = result.not_review_filter
      end
    end
    similarStatus = %w[Accepted Printing Printed Shipped Arrived Cancelled].intersection(filters)
    if similarStatus.length > 0
      result = result.status_filter(similarStatus)
    end
    result
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
