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

  has_one_attached :profile_picture

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :username, presence: true, uniqueness: true
  validates :password_confirmation, presence: true
  validates :country_id, presence: true

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
