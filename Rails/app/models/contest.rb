class Contest < ApplicationRecord
    before_destroy :set_deleted_at
    before_validation :set_start_at, on: [:create, :update]

    has_many :submissions

    has_one_attached :image

    validates :theme, presence: true, length: { maximum: 30 }
    validates :description, length: { maximum: 200 }
    validates :submission_limit, presence: true, numericality: { only_integer: true, greater_than: 0, less_than: 30 }
    # validates :image, presence: true

    validate :past?, on: [:create, :update]

    private

    def set_deleted_at
        self.deleted_at = Time.now.in_time_zone('America/Toronto')
    end

    def set_start_at
        if self.start_at.nil?
            self.start_at = Time.now
            debugger
        end
    end

    def past?
        if self.start_at < Time.now.change(sec: 0)
            errors.add(:start_at, "must be in the future")
        end

        if !self.end_at.nil?
            unless self.end_at > self.start_at + 1.day
                debugger
                errors.add(:end_at, "must be at least one day after start_at")
            end
        end
    end
end
