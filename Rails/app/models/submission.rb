# frozen_string_literal: true

class Submission < ApplicationRecord
  before_destroy :contest_finished?, if: -> { contest&.finished? }

  belongs_to :user
  belongs_to :contest

  has_one_attached :stl
  has_one_attached :image

  has_many :likes, dependent: :destroy

  validates :name, presence: true, length: { minimum: 3, maximum: 30 }
  validates :description, length: { maximum: 200 }
  validates :contest, presence: true
  validates :image, presence: true
  validates :stl, presence: true

  validate :stl_must_be_valid
  validate :image_must_be_valid
  validate :submissions_limit, on: :create, if: -> { contest.present? && user.present? }
  validate :contest_finished?, on: %i[create update], if: -> { contest&.finished? }
  validate :contest_started?, on: :create, if: -> { contest.present? }

  def stl_url
    stl && url_for(stl)
  end

  def image_url
    image && url_for(image)
  end

  private

  def contest_finished?
    errors.add(:contest, 'is closed')
    throw :abort
  end

  def contest_started?
    errors.add(:contest, 'has not started yet') unless contest&.started?
  end

  def submissions_limit
    user_submissions_for_contest = user.submissions.where(contest: contest).count

    return unless user_submissions_for_contest >= contest.submission_limit

    errors.add(:submission, 'has reached the submission limit for this contest')
  end

  def url_for(file)
    Rails.application.routes.url_helpers.rails_blob_url(file, only_path: true)
  end

  def stl_must_be_valid
    return unless stl.attached?

    filename = stl.filename.to_s
    extension = File.extname(filename)

    return if extension.downcase == '.stl'

    errors.add(:stl, 'must have .stl extension')
  end

  def image_must_be_valid
    return unless image.attached?

    return if image.content_type.in?(%w[image/png image/jpeg image/jpg])

    errors.add(:image, 'must be a PNG, JPG, or JPEG file')
  end
end
