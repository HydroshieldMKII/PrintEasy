# frozen_string_literal: true

class Contest < ApplicationRecord
  # before_validation :set_start_at, on: [:create, :update]

  default_scope { where(deleted_at: nil) }
  scope :active_for_user, lambda { |_user|
    where('start_at <= ?', Time.now)
  }

  has_many :submissions, dependent: :destroy
  has_many :likes, through: :submissions

  has_one_attached :image

  validates :theme, presence: true, length: { maximum: 30 }
  validates :description, length: { maximum: 200 }
  validates :submission_limit, presence: true, numericality: { only_integer: true, greater_than: 0, less_than: 30 }
  validates :start_at, presence: true
  validates :start_at, comparison: { greater_than_or_equal_to: lambda {
    Time.now
  }, message: 'must be in the future' }, on: :create
  validates :start_at, comparison: { greater_than: lambda {
    Time.now
  }, message: 'must be in the future' }, on: :update, if: lambda {
                                                        will_save_change_to_attribute?(:start_at)
                                                      }
  validates :start_at, comparison: { less_than: :end_at, message: 'must be before end_at' }, if: lambda {
    end_at.present?
  }
  validates :image, presence: true

  validate :contest_finished?, on: :update

  def winner_user
    return nil unless finished?

    top_submission = submissions
                     .left_joins(:likes)
                     .group(:id)
                     .order('COUNT(likes.id) DESC, submissions.created_at ASC')
                     .first

    top_submission&.user
  end

  def self.contests_order(user)
    user.accessible_contests
        .left_joins(submissions: :likes)
        .group('contests.id')
        .order(Arel.sql('
                      CASE
                        WHEN contests.end_at IS NOT NULL AND contests.end_at < CURRENT_DATE THEN 1
                        ELSE 0
                      END, contests.start_at'))
  end

  def users_with_submissions(current_user)
    # Get all distinct users in this contest
    users = User.joins(:submissions)
                .where(submissions: { contest_id: id })
                .distinct
                .order(:username)

    # Build the result array manually without using group_by or sort_by
    result = []

    users.each do |user|
      # For each user, get their submissions
      user_submissions = submissions.where(user_id: user.id)

      # Create the user entry
      user_entry = {
        user: user.as_json,
        submissions: user_submissions.as_json(
          include: :likes,
          methods: %i[image_url stl_url liked_by_current_user]
        ),
        mine: user.id == current_user.id
      }

      result << user_entry
    end

    result
  end

  def soft_delete
    update(deleted_at: Time.now)
  end

  def started?
    start_at && start_at < Time.now
  end

  def finished?
    return false unless end_at

    end_at < Time.now
  end

  def contest_finished?
    errors.add(:contest, 'is closed') if finished?
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
end
