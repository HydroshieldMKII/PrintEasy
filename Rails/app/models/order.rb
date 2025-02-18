class Order < ApplicationRecord
  belongs_to :offer
  has_many :order_status
  has_one :review

  validates :offer_id, presence: true, uniqueness: true

  def printer
    self.offer.printer_user.user
  end

  def consumer
    self.offer.request.user
  end
end
