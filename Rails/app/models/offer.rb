# frozen_string_literal: true

class Offer < ApplicationRecord
  belongs_to :request
  belongs_to :printer_user
  belongs_to :color
  belongs_to :filament
  has_one :order

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

  def reject!
    return false if Order.find_by(offer_id: id)
    return false if cancelled_at

    update_column(:cancelled_at, Time.now)
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
end
