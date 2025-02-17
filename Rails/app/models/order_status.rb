class OrderStatus < ApplicationRecord
  belongs_to :status, foreign_key: :status_name, primary_key: :name
  belongs_to :order

  has_one_attached :image

  validates :comment, length: { maximum: 200, minimum: 5 }
  validates :status_name, presence: true
  validates :order_id, presence: true
  validate :can_transition, on: :create

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

  

  private

  def can_transition()
    events = self.class.state_machine.events #[:cancel].branches[0].state_requirements[0][:from].values
    last_state = self.order.order_status.order(created_at: :desc).first#[event].known_states
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

end