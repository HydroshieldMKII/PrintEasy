# frozen_string_literal: true

class Contest < ApplicationRecord
  # before_validation :set_start_at, on: [:create, :update]

  default_scope { where(deleted_at: nil) }

  scope :active_for_user, lambda { |_user|
    where('start_at <= ?', Time.now)
  }

  scope :search, -> (search) {
    where('theme LIKE ?', "%#{search}%")
  }

  scope :active, ->(params) {
    return if !params.key?(:active)

    where('start_at <= ? AND (end_at IS NULL OR end_at >= ?)', Time.now, Time.now)
  }

  scope :finished, ->(params) {
    return if !params.key?(:finished)

    where('end_at < ?', Time.now)
  }

  scope :with_participants, ->(participants) {
    return if participants.blank?  
  
    joins(:submissions)
    .joins("LEFT JOIN users ON users.id = submissions.user_id")
    .group("contests.id")
    .having("COUNT(DISTINCT users.id) = ?", participants)
  }
  
  scope :sort_by_submissions, -> (direction_params) {
    return if direction_params.blank?

    direction = %w[asc desc].include?(direction_params) ? direction_params : "desc"
    left_joins(:submissions)
      .group(:id)
      .order("COUNT(submissions.id) #{direction.upcase}")
  }
  
  scope :sort_by_date, -> (category, sort) {
    return if sort.blank? || category.blank?
    
    allowed_columns = %w[start_at end_at]
    allowed_directions = %w[asc desc]

    column = allowed_columns.include?(category) ? category : "start_at"
    direction = allowed_directions.include?(sort) ? sort : "asc"

    order(Arel.sql('IF(contests.end_at IS NOT NULL AND contests.end_at < CURRENT_DATE, 1, 0)'), column => direction)
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

  def self.contests_order(user, params)
    contests = user.accessible_contests
                    .search(params[:search])
                    .active(params)
                    .finished(params)
                    .with_participants(params[:participants])
                    .sort_by_submissions(params[:sort_by_submissions])
                    .sort_by_date(params[:category], params[:sort])
                    .order(Arel.sql('
                      CASE 
                        WHEN contests.end_at IS NOT NULL AND contests.end_at < CURRENT_DATE THEN 1 
                        ELSE 0 
                      END, contests.start_at')
                    )
    contests
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
