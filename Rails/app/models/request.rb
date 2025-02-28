# frozen_string_literal: true

class Request < ApplicationRecord
  belongs_to :user
  has_many :offers, dependent: :destroy
  has_many :preset_requests, dependent: :destroy
  accepts_nested_attributes_for :preset_requests, allow_destroy: true

  validates :user_id, presence: true
  validates :name, presence: true, length: { in: 3..30 }
  validates :budget, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10_000 }
  validates :comment, length: { maximum: 200 }

  has_one_attached :stl_file

  # Create validations
  validates :stl_file, presence: true, on: :create
  validates :target_date, presence: true, comparison: { greater_than: Date.today }, on: :create

  # Update validations
  validate :target_date_cannot_be_in_the_past_on_update, on: :update
  validate :cannot_update_if_offer_accepted, on: :update

  validate :stl_file_must_have_stl_extension
  validate :unique_preset_requests

  # Helper
  def stl_file_url
    Rails.application.routes.url_helpers.rails_blob_url(stl_file, only_path: true)
  end

  def has_offer_made?
    offers.exists?
  end

  def has_offer_accepted?
    offers.joins(order: :order_status)
          .where(order_status: { status_name: 'Accepted' })
          .exists?
  end

  # Validations
  private

  def target_date_cannot_be_in_the_past_on_update
    return unless target_date_changed? && target_date < Date.today # https://api.rubyonrails.org/v7.1/classes/ActiveModel/Dirty.html

    errors.add(:target_date, 'must be greater than today')
  end

  def stl_file_must_have_stl_extension
    return unless stl_file.attached?

    filename = stl_file.filename.to_s
    extension = File.extname(filename)
    return if extension.downcase == '.stl'

    errors.add(:stl_file, 'must have .stl extension')
  end

  def cannot_update_if_offer_accepted
    return unless has_offer_accepted?

    errors.add(:base, 'Cannot update request with accepted offers')
  end

  def unique_preset_requests
    seen = {}
    preset_requests.each do |preset|
      key = [preset.color_id, preset.filament_id, preset.printer_id, preset.print_quality]
      if seen[key]
        preset.errors.add(:base, 'Duplicate preset exists in the request')
      else
        seen[key] = true
      end
    end
  end
end
