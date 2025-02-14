class Contest < ApplicationRecord
    before_destroy :set_deleted_at
    before_save :past?
    before_update :past?

    has_many :submissions

    has_one_attached :image

    validates :theme, presence: true, length: { maximum: 30 }
    validates :description, length: { maximum: 200 }
    validates :submission_limit, presence: true, numericality: { only_integer: true, greater_than: 0, less_than: 30 }
    validates :image, presence: true

    def active?
        self.start_at <= Time.now && Time.now <= self.end_at
    end

    private

    def set_deleted_at
        self.update(deleted_at: Time.now)
    end

    def past?
        if !self.start_at.nil? && !self.end_at.nil?
            self.end_at < self.start_at + 1.day
        end
    end
end
