class Request < ApplicationRecord
  belongs_to :user
  has_many :preset_requests, dependent: :destroy
  has_many :offers, dependent: :destroy

  validates :user_id, presence: true
  validates :name, presence: true, length: { in: 5..30 }
  validates :budget, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10_000 }
  validates :comment, length: { in: 5..200 }
  validates :target_date, presence: true, comparison: { greater_than: Date.today }

  has_one_attached :stl_file, format: { with: /\A.*\.stl\z/ }
end
