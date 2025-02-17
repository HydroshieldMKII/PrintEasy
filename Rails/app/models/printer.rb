class Printer < ApplicationRecord
  has_many :preset_requests, dependent: :destroy
end
