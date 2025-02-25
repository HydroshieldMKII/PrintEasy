class PrinterUser < ApplicationRecord
  belongs_to :printer
  belongs_to :user
  has_many :offer
end
