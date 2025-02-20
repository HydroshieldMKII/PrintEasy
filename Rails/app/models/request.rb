class Request < ApplicationRecord
  belongs_to :user
  has_many :offers, dependent: :destroy
  has_many :preset_requests, dependent: :destroy
  accepts_nested_attributes_for :preset_requests, allow_destroy: true

  validates :user_id, presence: true
  validates :name, presence: true, length: { in: 3..30 }
  validates :budget, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10_000 }
  validates :comment, length: { maximum: 200 }
  validates :target_date, presence: true, comparison: { greater_than: Date.today }, on: :create

  has_one_attached :stl_file
  validates :stl_file, presence: true, on: :create

  def stl_file_url
    return Rails.application.routes.url_helpers.rails_blob_url(stl_file, only_path: true)
  end

  def has_offer_made?
    return offers.exists?
  end

  def has_offer_accepted?
    offers.joins(order: :order_status)
          .where(order_status: { status_name: 'Accepted' })
          .exists?
  end
end
