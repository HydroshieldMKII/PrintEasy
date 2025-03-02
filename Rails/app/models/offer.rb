# frozen_string_literal: true

class Offer < ApplicationRecord
  belongs_to :request
  belongs_to :printer_user
  belongs_to :color
  belongs_to :filament
  has_one :order, dependent: :restrict_with_error

  # Add relation to user through printer_user for easier access
  has_one :user, through: :printer_user

  validates :print_quality, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 2 }
  validates :request, :printer_user, :color, :filament, presence: true
  validates :request, uniqueness: {
    scope: %i[printer_user_id color_id filament_id],
    message: 'This offer already exists'
  }, on: %i[create update], unless: :cancelled_at?
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10_000 }
  validates :target_date, presence: true, format: { with: /\A\d{4}-\d{2}-\d{2}\z/ }

  validate :target_date_greater_than_today, on: %i[create update]
  validate :not_own_request, on: :create
  validate :user_must_have_printer, on: :create
  validate :user_must_own_printer, on: :create
  validate :request_not_already_accepted, on: :create

  with_options on: :update do |offer|
    offer.validate :cannot_update_if_accepted
    offer.validate :cannot_update_if_cancelled
  end

  with_options on: :destroy do |offer|
    offer.validate :cannot_delete_if_accepted
    offer.validate :cannot_delete_if_cancelled
  end

  scope :not_accepted, lambda {
    where.not(id: Order.select(:offer_id))
  }

  scope :not_in_accepted_request, lambda {
    not_accepted.where.not(request_id: Request.joins(offers: :order).select(:id).distinct)
  }

  scope :for_user_requests, lambda {
    not_accepted.where(request: Current.user.requests)
  }

  scope :from_user_printers, lambda {
    not_accepted.where(printer_user: Current.user.printer_user)
  }

  def rejected?
    cancelled_at.present?
  end

  def accepted?
    Order.exists?(offer_id: id)
  end

  # Simplified reject method with validation moved to can_reject?
  def reject!
    return false if accepted? || rejected?

    update_column(:cancelled_at, Time.now)
  end

  def can_reject?
    errors.clear

    if accepted?
      errors.add(:offer, 'Offer already accepted. Cannot reject')
      return false
    end

    if rejected?
      errors.add(:offer, 'Offer already rejected')
      return false
    end

    if Current.user != user
      errors.add(:offer, 'You are not allowed to reject this offer')
      return false
    end

    true
  end

  def can_destroy?
    errors.clear

    if accepted?
      errors.add(:offer, 'Offer already accepted. Cannot delete')
      return false
    end

    if rejected?
      errors.add(:offer, 'Offer already rejected. Cannot delete')
      return false
    end

    true
  end

  def destroy
    return false if rejected? || accepted?

    super
  end

  private

  def target_date_greater_than_today
    return unless target_date.present? && target_date <= Date.today && target_date_changed?

    errors.add(:target_date, 'must be greater than today')
  end

  def cannot_update_if_accepted
    return unless accepted?

    errors.add(:offer, 'Offer already accepted. Cannot update')
  end

  def cannot_update_if_cancelled
    return unless rejected?

    errors.add(:offer, 'Offer already rejected. Cannot update')
  end

  def cannot_delete_if_accepted
    return unless accepted?

    errors.add(:offer, 'Offer already accepted. Cannot delete')
  end

  def cannot_delete_if_cancelled
    return unless rejected?

    errors.add(:offer, 'Offer already rejected. Cannot delete')
  end

  def request_not_already_accepted
    accepted_request_ids = Order.joins(:offer).select(:request_id).distinct
    return unless accepted_request_ids.include?(request_id)

    errors.add(:offer, 'Request already accepted an offer. Cannot create')
  end

  def user_must_have_printer
    return if Current.user&.printer_user&.exists?

    errors.add(:offer, 'You need to have a printer to create an offer')
  end

  def user_must_own_printer
    return if printer_user_id.blank?
    return if Current.user.printer_user.select(:id).map(&:id).include?(printer_user_id)

    errors.add(:offer, 'You are not allowed to create an offer on this printer')
  end

  def not_own_request
    return if request_id.blank?

    req = Request.find_by(id: request_id)
    return if req.nil? || req.user_id != Current.user.id

    errors.add(:offer, 'You cannot create an offer on your own request')
  end
end
