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
  validate :user_can_modify, on: [:destroy, :update]
  validate :can_create_state, on: :create
  validate :can_transition, on: :create
  validate :state_valid?
  before_destroy :can_destroy?, prepend: true
  before_destroy :is_frozen?, prepend: true
  before_update :is_frozen?, prepend: true

  StateMachines::Machine.ignore_method_conflicts = true

  state_machine :status_name, :initial => lambda { |order_status| order_status.status_name || 'Accepted' } do

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
      transition ['Accepted', 'Printing', 'Printed'] => 'Cancelled'
    end
  end

  def consumer
    self.order.offer.request.user
  end

  def printer
    self.order.offer.printer_user.user
  end

  def available_status
    events = self.class.state_machine.events
    available = []
    events.each do |event|
      from = event.branches[0].state_requirements[0][:from].values
      to = event.branches[0].state_requirements[0][:to].values
      if from.include?(self.status_name)
        available.push(to)
      end
    end
    available.flatten!
    # available.delete('Cancelled')
    return available
  end

  def image_url
    Rails.application.routes.url_helpers.rails_blob_url(self.image, only_path: true) if self.image.attached?
  end

  class CannotDestroyStatusError < StandardError; end
  class OrderStatusFrozenError < StandardError; end

  private

  def can_transition()
    events = self.class.state_machine.events
    last_state = self.order&.order_status&.order(created_at: :desc)&.first
    if !last_state.nil?
      events.each do |event|
        from = event.branches[0].state_requirements[0][:from].values
        to = event.branches[0].state_requirements[0][:to].values
        if from.include?(last_state.status_name) && to.include?(self.status_name)
          return true
        end
      end

      errors.add(:status_name, "Invalid transition from #{last_state.status_name} to #{self.status_name}")
      return false
    end
    return true
  end

  def user_can_create_status()
    if self.order.printer == Current.user || self.order.consumer == Current.user
      return true
    end
    errors.add(:order_status, "You are not authorized to create a new status for this order")
    return false
  end

  def user_can_modify()
    if self.order.printer == Current.user
      return true
    end
    errors.add(:order_status, "You are not authorized to delete this status")
    return false
  end

  def order_id_exists
    if Order.find_by(id: self.order_id).nil?
      errors.add(:order_id, "Order does not exist")
      throw(:abort)
    end
    return true
  end

  def can_create_state()
    last_state = self.order&.order_status&.order(created_at: :desc)&.first.status_name
    if Current.user == self.order.consumer
      if ['Cancelled', 'Accepted', 'Printing', 'Printed', 'Shipped'].include?(self.status_name)
        if self.status_name == 'Cancelled'
          if last_state != 'Accepted'
            errors.add(:order_status, "Invalid transition from #{last_state} to #{self.status_name}")
            return false
          end
        else
          if last_state == nil
            return true
          end
          errors.add(:order_status, "Invalid transition from #{last_state} to #{self.status_name}")
          return false
        end
      end
    elsif Current.user == self.order.printer
      if self.status_name == 'Arrived'
        errors.add(:order_status, "Invalid transition from #{last_state} to Arrived")
        return false
      end
    end
    return true
  end

  def can_destroy?
    if ['Accepted', 'Cancelled', 'Arrived', 'Shipped'].include?(self.status_name)
      raise CannotDestroyStatusError, "Cannot delete the status"
    end
    return true
  end

  def is_frozen?
    last_state = self.order&.order_status&.order(created_at: :desc)&.first
    if ['Cancelled', 'Arrived', 'Shipped'].include?(last_state.status_name)
      raise OrderStatusFrozenError, "Cannot change status of a frozen order"
    end
    return true
  end

  def state_valid?
    states = self.class.state_machine.states.map(&:name)
    if !states.include?(self.status_name)
      errors.add(:status_name, "Invalid status")
    end
  end
end