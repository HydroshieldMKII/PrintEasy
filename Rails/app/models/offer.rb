# frozen_string_literal: true

class Offer < ApplicationRecord
  belongs_to :request
  belongs_to :printer_user
  belongs_to :color
  belongs_to :filament
  has_one :order, dependent: :restrict_with_error

  validates :print_quality, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 2 }
  validates :request, :printer_user, :color, :filament, presence: true
  validates :request, uniqueness: { scope: %i[printer_user_id color_id filament_id], message: 'This offer already exists' },
                      on: %i[create update], unless: :cancelled_at?
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10_000 }
  validates :target_date, presence: true, format: { with: /\A\d{4}-\d{2}-\d{2}\z/ }

  validate :target_date_greater_than_today, on: %i[create update]
  validate :cannot_update_if_accepted, on: %i[update]
  validate :cannot_update_if_cancelled, on: %i[update]
  validate :cannot_delete_if_accepted, on: %i[destroy]
  validate :cannot_delete_if_cancelled, on: %i[destroy]
  validate :request_not_already_accepted, on: %i[create]

  validate :user_must_have_printer, on: :create
  validate :user_must_own_printer, on: :create
  validate :not_own_request, on: :create

  scope :not_in_accepted_request, lambda {
    accepted_requests = Order.joins(:offer).pluck(:request_id).uniq
    where.not(id: Order.pluck(:offer_id)).where.not(request_id: accepted_requests)
  }

  scope :for_user_requests, lambda { |user|
    where(request_id: user.requests.pluck(:id)).where.not(id: Order.pluck(:offer_id)).distinct
  }

  scope :from_user_printers, lambda { |user|
    where(printer_user_id: user.printer_user.pluck(:id)).where.not(id: Order.pluck(:offer_id)).distinct
  }

  def reject!
    return false if Order.find_by(offer_id: id)
    return false if cancelled_at

    update_column(:cancelled_at, Time.now)
  end

  def can_reject?(user)
    valid = true

    if Order.find_by(offer_id: id)
      errors.add(:offer, 'Offer already accepted. Cannot reject')
      valid = false
    end

    if request.user != user
      errors.add(:offer, 'You are not allowed to reject this offer')
      valid = false
    end

    if cancelled_at
      errors.add(:offer, 'Offer already rejected')
      valid = false
    end

    valid
  end

  def can_destroy?
    if Order.exists?(offer_id: id)
      errors.add(:offer, 'Offer already accepted. Cannot delete')
      return false
    end

    if cancelled_at
      errors.add(:offer, 'Offer already rejected. Cannot delete')
      return false
    end

    true
  end

  def destroy
    return false if cancelled_at || Order.exists?(offer_id: id)

    super
  end

  private

  def target_date_greater_than_today
    return unless target_date.present? && target_date <= Date.today && target_date_changed?

    errors.add(:target_date, 'must be greater than today')
  end

  def cannot_update_if_accepted
    return unless Order.find_by(offer_id: id)

    errors.add(:offer, 'Offer already accepted. Cannot update')
  end

  def cannot_update_if_cancelled
    return unless cancelled_at

    errors.add(:offer, 'Offer already rejected. Cannot update')
  end

  def cannot_delete_if_accepted
    return unless Order.exists?(offer_id: id)

    errors.add(:offer, 'Offer already accepted. Cannot delete')
  end

  def cannot_delete_if_cancelled
    return unless cancelled_at

    errors.add(:offer, 'Offer already rejected. Cannot delete')
  end

  def request_not_already_accepted
    accepted_requests = Order.joins(:offer).pluck(:request_id).uniq
    return unless accepted_requests.include?(request_id)

    errors.add(:offer, 'Request already accepted an offer. Cannot create')
  end

  # New validation methods
  def user_must_have_printer
    return if Current.user&.printer_user&.exists?

    errors.add(:offer, 'You need to have a printer to create an offer')
  end

  def user_must_own_printer
    return if printer_user_id.blank?
    return if Current.user.printer_user.pluck(:id).include?(printer_user_id)

    errors.add(:offer, 'You are not allowed to create an offer on this printer')
  end

  def not_own_request
    return if request_id.blank?

    req = Request.find_by(id: request_id)
    return if req.nil? || req.user_id != Current.user.id

    errors.add(:offer, 'You cannot create an offer on your own request')
  end
end
