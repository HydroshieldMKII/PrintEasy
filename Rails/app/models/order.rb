class Order < ApplicationRecord
  belongs_to :offer
  has_many :order_status

  validates :offer_id, presence: true, uniqueness: true
end
