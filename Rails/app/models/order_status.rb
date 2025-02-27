# frozen_string_literal: true

class OrderStatus < ApplicationRecord
  belongs_to :status, foreign_key: :status_name, primary_key: :name
  belongs_to :order

  has_one_attached :image

  validates :comment, length: { maximum: 200 }
  validates :comment, length: { minimum: 5 }, if: -> { comment.present? }
  validates :status_name, presence: true
  validates :order_id, presence: true
  validate :order_id_exists, on: :create
  validate :user_can_create_status
  validate :user_can_modify, on: %i[destroy update]
  validate :can_create_state, on: :create
  validate :can_transition, on: :create
  validate :state_valid?
  before_destroy :can_destroy?, prepend: true
  before_destroy :is_frozen?, prepend: true
  before_update :is_frozen?, prepend: true

  StateMachines::Machine.ignore_method_conflicts = true

  state_machine :status_name, initial: ->(order_status) { order_status.status_name || 'Accepted' } do
    event :reaccept do
      transition 'Accepted' => 'Accepted'
    end

    event :print do
      transition 'Accepted' => 'Printing'
    end

    event :reprint do
      transition 'Printing' => 'Printing'
    end

    event :complete do
      transition 'Printing' => 'Printed'
    end

    event :recomplete do
      transition 'Printed' => 'Printed'
    end

    event :ship do
      transition 'Printed' => 'Shipped'
    end

    event :arrive do
      transition 'Shipped' => 'Arrived'
    end

    event :cancel do
      transition %w[Accepted Printing Printed] => 'Cancelled'
    end
  end

  def consumer
    order.offer.request.user
  end

  def printer
    order.offer.printer_user.user
  end

  def available_status
    events = self.class.state_machine.events
    available = []
    events.each do |event|
      from = event.branches[0].state_requirements[0][:from].values
      to = event.branches[0].state_requirements[0][:to].values
      available.push(to) if from.include?(status_name)
    end
    available.flatten!
    if Current.user == consumer
      available.delete('Cancelled') if status_name != 'Accepted'
      available.delete('Accepted')
      available.delete('Printing')
      available.delete('Printed')
      available.delete('Shipped')
    elsif Current.user == printer
      available.delete('Arrived')
    end

    available
  end

  def image_url
    Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true) if image.attached?
  end

  class CannotDestroyStatusError < StandardError; end
  class OrderStatusFrozenError < StandardError; end

  private

  def can_transition
    events = self.class.state_machine.events
    last_state = order&.order_status&.order(created_at: :desc)&.first
    unless last_state.nil?
      events.each do |event|
        from = event.branches[0].state_requirements[0][:from].values
        to = event.branches[0].state_requirements[0][:to].values
        return true if from.include?(last_state.status_name) && to.include?(status_name)
      end

      errors.add(:status_name, "Invalid transition from #{last_state.status_name} to #{status_name}")
      return false
    end
    true
  end

  def user_can_create_status
    return true if order.printer == Current.user || order.consumer == Current.user

    errors.add(:order_status, 'You are not authorized to create a new status for this order')
    false
  end

  def user_can_modify
    return true if order.printer == Current.user

    errors.add(:order_status, 'You are not authorized to delete this status')
    false
  end

  def order_id_exists
    if Order.find_by(id: order_id).nil?
      errors.add(:order_id, 'Order does not exist')
      throw(:abort)
    end
    true
  end

  def can_create_state
    last_state = order&.order_status&.order(created_at: :desc)&.first&.status_name
    if Current.user == order.consumer
      if %w[Cancelled Accepted Printing Printed Shipped].include?(status_name)
        if status_name == 'Cancelled'
          if last_state != 'Accepted'
            errors.add(:order_status, "Invalid transition from #{last_state} to #{status_name}")
            return false
          end
        else
          return true if last_state.nil?

          errors.add(:order_status, "Invalid transition from #{last_state} to #{status_name}")
          return false
        end
      end
    elsif Current.user == order.printer
      if status_name == 'Arrived'
        errors.add(:order_status, "Invalid transition from #{last_state} to Arrived")
        return false
      end
    end
    true
  end

  def can_destroy?
    if %w[Accepted Cancelled Arrived Shipped].include?(status_name)
      return true if status_name == 'Accepted' && order.order_status.where(status_name: 'Accepted').count > 1

      raise CannotDestroyStatusError, 'Cannot delete the status'
    end
    true
  end

  def is_frozen?
    last_state = order&.order_status&.order(created_at: :desc)&.first
    if %w[Cancelled Arrived Shipped].include?(last_state.status_name)
      raise OrderStatusFrozenError, 'Cannot change status of a frozen order'
    end

    true
  end

  def state_valid?
    states = self.class.state_machine.states.map(&:name)
    return if states.include?(status_name)

    errors.add(:status_name, 'Invalid status')
  end
end
