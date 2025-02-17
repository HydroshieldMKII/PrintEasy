class Request < ApplicationRecord
  belongs_to :user
  has_many :preset_requests, dependent: :destroy
  has_many :offers, dependent: :destroy

  validates :user_id, presence: true
  validates :name, presence: true, length: { in: 5..30 }
  validates :budget, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10_000 }
  validates :comment, length: { in: 5..200 }
  validates :target_date, presence: true, comparison: { greater_than: Date.today }

  has_many_attached :stl_file
  validates :stl_file, presence: true

  def stl_file_url
    return unless stl_file.attached?

    stl_file.map do |file|
      Rails.application.routes.url_helpers.rails_blob_url(file, only_path: true)
    end
  end
end
