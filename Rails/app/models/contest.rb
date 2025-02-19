class Contest < ApplicationRecord
    before_validation :set_start_at, on: [:create, :update]

    default_scope { where(deleted_at: nil) }

    has_many :submissions

    has_one_attached :image

    validates :theme, presence: true, length: { maximum: 30 }
    validates :description, length: { maximum: 200 }
    validates :submission_limit, presence: true, numericality: { only_integer: true, greater_than: 0, less_than: 30 }
    # validates :image, presence: true

    validate :past?, on: [:create, :update]

    def soft_delete
        update(deleted_at: Time.now)
    end

    def restore
        update(deleted_at: nil)
    end

    def deleted?
        !deleted_at.nil?
    end

    def image_url
        image && Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
    end

    private

    def set_start_at
        if self.start_at.nil?
            self.start_at = Time.now
        end
    end

    def past?
        return if deleted_at_changed?

        if self.start_at < Time.now.change(sec: 0)
            errors.add(:start_at, "must be in the future")
        end

        if !self.end_at.nil?
            if self.end_at < self.start_at + 1.day
                errors.add(:end_at, "must be at least one day after start_at")
            end
        end
    end
end
