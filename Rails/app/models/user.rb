# frozen_string_literal: true

class User < ApplicationRecord
  belongs_to :country
  has_many :presets, dependent: :destroy
  has_many :requests, dependent: :destroy
  has_many :submissions, dependent: :destroy
  has_many :printer_users, dependent: :destroy
  has_many :printers, through: :printer_users
  has_many :offers, through: :printer_users
  has_many :likes
  has_many :liked_submissions, through: :likes, source: :submission
  has_many :contests, -> { distinct }, through: :submissions
  has_many :likes_received, through: :submissions, source: :likes

  has_one_attached :profile_picture

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :username, presence: true, uniqueness: true
  validates :password_confirmation, presence: true
  validates :country_id, presence: true

 
  # def won_contests
  #   contests.where("contests.end_at <= ?", Time.now) 
  #          .select { |contest| contest.winner_user&.dig("id") == id }
  # end


  # find how many contests the user has won
  # the not exists subquery is to find submissions who have the same amount of likes but were created before the current submission or more likes than the current
  # not exists if true means that there is no other submissions that have the same amount or like or more
  # not exists if false means that there is another submission that has the same amount of likes or more
  def won_contests
    contests
      .joins(:submissions)
      .joins("LEFT JOIN likes ON likes.submission_id = submissions.id")
      .where("contests.end_at <= ?", Time.now)
      .where("submissions.user_id = ?", id)
      .where(
        "NOT EXISTS (
          SELECT 1
          FROM submissions s2
          LEFT JOIN likes l2 ON l2.submission_id = s2.id
          WHERE s2.contest_id = contests.id
          GROUP BY s2.id, s2.created_at
          HAVING COUNT(l2.id) > COUNT(likes.id)
             OR (COUNT(l2.id) = COUNT(likes.id) AND s2.created_at < submissions.created_at)
        )"
      )
      .group("contests.id, submissions.id, submissions.user_id, submissions.created_at")
      .having("COUNT(likes.id) > 0")
      .distinct
  end

  def wins_count
    won_contests.length
  end

  def accessible_contests
    is_admin? ? Contest.all : Contest.active_for_user(self)
  end

  def user_contests_submissions
    contests = Contest.joins(:submissions).where(submissions: { user_id: id }).distinct

    contests.map do |contest|
      contest_data = contest.as_json(methods: %i[image_url finished? started? winner_user])
      {
        contest: contest_data,
        submissions: contest.submissions.where(user_id: id)
                            .as_json(include: :likes, methods: %i[image_url stl_url liked_by_current_user])
      }
    end
  end

  def email_required?
    false
  end

  def will_save_change_to_email?
    false
  end

  def profile_picture_url
    return unless profile_picture.attached?

    Rails.application.routes.url_helpers.rails_blob_url(profile_picture,
                                                        only_path: true)
  end

  def self_reviews
    Review.joins(order: { offer: :printer_user })
          .where('printer_users.user_id = ?', id)
          .map do |review|
      review.as_json(
        methods: %i[image_urls],
        include: {
          user: {
            except: %i[country_id],
            include: { country: {} },
            methods: %i[profile_picture_url]
          }
        }
      )
    end
  end
end
