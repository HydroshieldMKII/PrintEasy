class Color < ApplicationRecord
  validates :name, presence: true, length: { maximum: 30 }, format: { with: /[a-zA-Z]/ }
end
