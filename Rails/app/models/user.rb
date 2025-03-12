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

  # find how many contests the user has won
  # the not exists subquery is to find submissions who have the same amount of likes but were created before the current submission or more likes than the current
  # not exists if true means that there is no other submissions that have the same amount or like or more
  # not exists if false means that there is another submission that has the same amount of likes or more
  def self.stats(category:, direction:, start_date:, end_date:)
    valid_order_columns = ['wins_count', 'submission_rate', 'participations', 'total_likes', 'winrate']

    category = valid_order_columns.include?(category) ? category : 'wins_count'
  
    direction = ['asc', 'desc'].include?(direction) ? direction : 'desc'
    
    sanitized_start_date = start_date.present? ? ActiveRecord::Base.connection.quote(start_date) : Date.new(2000, 1, 1).strftime('%Y-%m-%d')
    sanitized_end_date = end_date.present? ? ActiveRecord::Base.connection.quote(end_date) : Date.today.strftime('%Y-%m-%d')

    if sanitized_start_date > sanitized_end_date
      sanitized_start_date, sanitized_end_date = sanitized_end_date, sanitized_start_date
    end

    if sanitized_end_date > Date.today.strftime('%Y-%m-%d') || sanitized_end_date < Date.new(2000, 1, 1).strftime('%Y-%m-%d')
      sanitized_end_date = Date.today.strftime('%Y-%m-%d')
    end

    if sanitized_start_date < Date.new(2000, 1, 1).strftime('%Y-%m-%d') || sanitized_start_date > Date.today.strftime('%Y-%m-%d')
      sanitized_start_date = Date.new(2000, 1, 1).strftime('%Y-%m-%d')
    end

    year_condition = ""
    year_condition = "AND contests.start_at BETWEEN '#{sanitized_start_date}' AND '#{sanitized_end_date}'"
    
    sql = <<-SQL
      WITH contests_won AS (
        SELECT COUNT(DISTINCT contests.id) AS wins_count, submissions.user_id
        FROM contests
        LEFT JOIN submissions ON contests.id = submissions.contest_id
        LEFT JOIN likes ON likes.submission_id = submissions.id
        WHERE contests.deleted_at IS NULL
          AND contests.end_at <= NOW()
          #{year_condition}
          AND NOT EXISTS (
            SELECT 1
            FROM submissions s2
            LEFT JOIN likes l2 ON l2.submission_id = s2.id
            WHERE s2.contest_id = contests.id
            GROUP BY s2.id, s2.created_at
            HAVING COUNT(l2.id) > COUNT(likes.id)
               OR (COUNT(l2.id) = COUNT(likes.id) AND s2.created_at < submissions.created_at)
          )
        GROUP BY submissions.user_id
      ),
      submission_ratio AS (
        SELECT AVG(submission_ratio) AS submission_rate, ratios.user_id
        FROM (
          SELECT contests.id, contests.submission_limit,  
                 (COUNT(submissions.id) / contests.submission_limit) AS submission_ratio,
                 submissions.user_id
          FROM submissions
          LEFT JOIN contests ON contests.id = submissions.contest_id
          WHERE contests.deleted_at IS NULL
          #{year_condition}
          GROUP BY contests.id, submissions.user_id
          HAVING COUNT(submissions.id) <= contests.submission_limit
        ) AS ratios
        GROUP BY ratios.user_id
      ),
      participations AS (
        SELECT COUNT(DISTINCT contests.id) AS participations, submissions.user_id
        FROM contests
        LEFT JOIN submissions ON contests.id = submissions.contest_id
        WHERE contests.deleted_at IS NULL
        #{year_condition}
        GROUP BY submissions.user_id
      ),
      total_likes AS (
        SELECT COUNT(*) AS total_likes, submissions.user_id
        FROM likes
        LEFT JOIN submissions ON likes.submission_id = submissions.id
        INNER JOIN contests ON contests.id = submissions.contest_id
        WHERE submissions.user_id IS NOT NULL
        #{year_condition}
        GROUP BY submissions.user_id
      ),
      winrate AS (
        SELECT
          contests_won.user_id,
          CASE
            WHEN participations.participations = 0 THEN 0
            ELSE ROUND((contests_won.wins_count * 1.0 / participations.participations) * 100, 2)
          END AS winrate
        FROM contests_won
        LEFT JOIN participations ON contests_won.user_id = participations.user_id
      )
      SELECT
        users.username AS username,
        COALESCE(contests_won.wins_count, 0) AS wins_count,
        COALESCE(submission_ratio.submission_rate * 100, 0) AS submission_rate,
        COALESCE(participations.participations, 0) AS participations,
        COALESCE(total_likes.total_likes, 0) AS total_likes,
        COALESCE(winrate.winrate, 0) AS winrate
      FROM users
      LEFT JOIN contests_won ON users.id = contests_won.user_id
      LEFT JOIN submission_ratio ON users.id = submission_ratio.user_id
      LEFT JOIN participations ON users.id = participations.user_id
      LEFT JOIN total_likes ON users.id = total_likes.user_id
      LEFT JOIN winrate ON users.id = winrate.user_id
      ORDER BY #{category} #{direction};
    SQL
    
    results = ActiveRecord::Base.connection.select_all(ActiveRecord::Base.sanitize_sql_array([sql])).to_a

    results
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

  def contests_count
    contests.count
  end

  def likes_received_count
    likes_received.count
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
