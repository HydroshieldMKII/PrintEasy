class Printer < ApplicationRecord
  has_many :preset_requests, dependent: :destroy
  has_many :users, through: :printer_users
end
