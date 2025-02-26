class Contest < ApplicationRecord
    # before_validation :set_start_at, on: [:create, :update]

    default_scope { where(deleted_at: nil) }

    has_many :submissions

    has_one_attached :image

    validates :theme, presence: true, length: { maximum: 30 }
    validates :description, length: { maximum: 200 }
    validates :submission_limit, presence: true, numericality: { only_integer: true, greater_than: 0, less_than: 30 }
    validates :start_at, presence: true
    validates :start_at, comparison: { greater_than: -> { Time.now }, message: "must be in the future" }, on: :create 
    validates :start_at, comparison: { greater_than: -> { Time.now }, message: "must be in the future" }, on: :update, if: -> { will_save_change_to_attribute?(:start_at) }
    validates :start_at, comparison: { less_than: :end_at, message: "must be before end_at" }, if: -> { end_at.present? }
    validates :image, presence: true

    validate :contest_finished?, on: :update

    def soft_delete
        update(deleted_at: Time.now)
    end

    def finished?
        end_at && end_at < Time.now
    end

    def contest_finished?
        errors.add(:contest, "is closed") if finished?
    end

    def restore
        update(delaeted_at: nil)
    end

    def deleted?
        !deleted_at.nil?
    end

    def image_url
        image && Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
    end
end
