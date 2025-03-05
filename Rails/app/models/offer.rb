# frozen_string_literal: true

class Offer < ApplicationRecord
  belongs_to :request
  belongs_to :printer_user
  belongs_to :color
  belongs_to :filament
  has_one :order, dependent: :restrict_with_error
  has_one :user, through: :printer_user
  has_many :order_status, through: :order

  before_destroy :can_destroy?, prepend: true

  # https://apidock.com/rails/Object/with_options
  with_options presence: true do |offer|
    offer.validates :print_quality, numericality: { greater_than: 0, less_than_or_equal_to: 2 }
    offer.validates :request
    offer.validates :printer_user
    offer.validates :color
    offer.validates :filament
    offer.validates :price, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10_000 }
    offer.validates :target_date, format: { with: /\A\d{4}-\d{2}-\d{2}\z/ }
  end

  with_options on: %i[create update] do |offer|
    offer.validate :target_date_greater_than_today
    offer.validates :request, uniqueness: {
      scope: %i[printer_user_id color_id filament_id],
      message: 'This offer already exists'
    }
  end

  with_options on: :create do |offer|
    offer.validate :not_own_request
    offer.validate :user_must_have_printer
    offer.validate :user_must_own_printer
    offer.validate :request_not_already_accepted
  end

  with_options on: :update do |offer|
    offer.validate :cannot_update_if_accepted
    offer.validate :cannot_update_if_cancelled
  end

  with_options on: :destroy do |offer|
    offer.validate :cannot_delete_if_accepted
    offer.validate :cannot_delete_if_cancelled
  end

  scope :not_accepted, -> { where.not(id: Order.select(:offer_id)) }

  scope :not_in_accepted_request, lambda {
    not_accepted.where.not(request_id: Request.joins(offers: :order))
  }

  scope :for_user_requests, lambda {
    where(request_id: Request.where(user: Current.user))
  }

  scope :from_user_printers, lambda {
    where(printer_user_id: PrinterUser.where(user: Current.user))
  }

  def self.filter_by_type(type)
    case type
    when 'all' # Offers received on my requests
      not_in_accepted_request.for_user_requests
    when 'mine' # Offers sent to another user's requests
      from_user_printers
    else
      none
    end
  end

  # Single offer
  def serialize
    as_json(
      except: %i[request_id printer_user_id created_at updated_at color_id filament_id],
      include: {
        printer_user: {
          only: %i[id],
          include: {
            user: {
              only: %i[id username],
              include: { country: {} }
            },
            printer: { only: %i[id model] }
          }
        },
        color: {},
        filament: {}
      },
      methods: %i[accepted_at]
    )
  end

  # Grouping and serializing offers by request
  def self.group_by_request(offers)
    return [] if offers.empty?

    request_ids = offers.pluck(:request_id).uniq
    requests = Request.where(id: request_ids)
                      .includes(:user, offers: [
                                  { printer_user: %i[user printer] },
                                  :color,
                                  :filament
                                ])

    requests.as_json(
      include: {
        offers: {
          except: %i[request_id printer_user_id created_at updated_at color_id filament_id],
          include: {
            printer_user: {
              only: [:id],
              include: {
                user: {
                  only: %i[id username],
                  include: { country: {} }
                },
                printer: { only: %i[id model] }
              }
            },
            color: {},
            filament: {}
          },
          methods: %i[accepted_at]
        }
      }
    )
  end

  def rejected?
    cancelled_at.present?
  end

  def accepted?
    Order.exists?(offer_id: id)
  end

  def reject!
    if accepted?
      errors.add(:offer, 'Offer already accepted. Cannot reject')
      return false
    end

    if rejected?
      errors.add(:offer, 'Offer already rejected')
      return false
    end

    if request.user != Current.user
      errors.add(:offer, 'You are not allowed to reject this offer')
      return false
    end

    update_column(:cancelled_at, Time.now)
  end

  def can_reject?
    if accepted?
      errors.add(:offer, 'Offer already accepted. Cannot reject')
      return false
    end

    if rejected?
      errors.add(:offer, 'Offer already rejected')
      return false
    end

    if request.user != Current.user
      errors.add(:offer, 'You are not allowed to reject this offer')
      return false
    end

    true
  end

  def can_destroy?
    if accepted?
      errors.add(:offer, 'Offer already accepted. Cannot delete')
      throw(:abort)
    end

    return unless rejected?

    errors.add(:offer, 'Offer already rejected. Cannot delete')
    throw(:abort)
  end

  def accepted_at
    return unless accepted?

    Order.find_by(offer_id: id).order_status.first.created_at
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
    return unless request && Order.joins(:offer).exists?(offers: { request_id: request_id })

    errors.add(:offer, 'Request already accepted an offer. Cannot create')
  end

  def user_must_have_printer
    return if PrinterUser.exists?(user: Current.user)

    errors.add(:offer, 'You need to have a printer to create an offer')
  end

  def user_must_own_printer
    return if printer_user_id.blank?
    return if PrinterUser.where(user: Current.user, id: printer_user_id).exists?

    errors.add(:offer, 'You are not allowed to create an offer on this printer')
  end

  def not_own_request
    return if request_id.blank?

    req = Request.find_by(id: request_id)
    return if req.nil? || req.user != Current.user

    errors.add(:offer, 'You cannot create an offer on your own request')
  end
end
