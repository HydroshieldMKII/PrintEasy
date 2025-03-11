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
  def self.stats(order_by:, direction:, start_date:, end_date:)
    valid_order_columns = ['wins_count', 'submissions_participation_rate', 'contests_count', 'likes_received_count', 'winrate']
   
    order_by = valid_order_columns.include?(order_by) ? order_by : 'wins_count'
   
    direction = ['ASC', 'DESC'].include?(direction) ? direction : 'DESC'
    
    start_date ||= Date.new(2000, 1, 1).strftime('%Y-%m-%d')
    end_date ||= Date.today.strftime('%Y-%m-%d')

    if start_date > end_date
      start_date, end_date = end_date, start_date
    end

    if end_date > Date.today.strftime('%Y-%m-%d') || end_date < Date.new(2000, 1, 1).strftime('%Y-%m-%d')
      end_date = Date.today.strftime('%Y-%m-%d')
    end

    if start_date < Date.new(2000, 1, 1).strftime('%Y-%m-%d') || start_date > Date.today.strftime('%Y-%m-%d')
      start_date = Date.new(2000, 1, 1).strftime('%Y-%m-%d')
    end

    year_condition = ""
    year_condition = "AND contests.start_at BETWEEN '#{start_date}' AND '#{end_date}'"
    
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
        SELECT AVG(submission_ratio) AS submissions_participation_rate, ratios.user_id
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
      contests_count AS (
        SELECT COUNT(DISTINCT contests.id) AS contests_count, submissions.user_id
        FROM contests
        LEFT JOIN submissions ON contests.id = submissions.contest_id
        WHERE contests.deleted_at IS NULL
        #{year_condition}
        GROUP BY submissions.user_id
      ),
      likes_received_count AS (
        SELECT COUNT(*) AS likes_received_count, submissions.user_id
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
            WHEN contests_count.contests_count = 0 THEN 0
            ELSE ROUND((contests_won.wins_count * 1.0 / contests_count.contests_count) * 100, 2)
          END AS winrate
        FROM contests_won
        LEFT JOIN contests_count ON contests_won.user_id = contests_count.user_id
      )
      SELECT
        users.username AS username,
        COALESCE(contests_won.wins_count, 0) AS wins_count,
        COALESCE(submission_ratio.submissions_participation_rate * 100, 0) AS submissions_participation_rate,
        COALESCE(contests_count.contests_count, 0) AS contests_count,
        COALESCE(likes_received_count.likes_received_count, 0) AS likes_received_count,
        COALESCE(winrate.winrate, 0) AS winrate
      FROM users
      LEFT JOIN contests_won ON users.id = contests_won.user_id
      LEFT JOIN submission_ratio ON users.id = submission_ratio.user_id
      LEFT JOIN contests_count ON users.id = contests_count.user_id
      LEFT JOIN likes_received_count ON users.id = likes_received_count.user_id
      LEFT JOIN winrate ON users.id = winrate.user_id
      ORDER BY #{order_by} #{direction};
    SQL
    
    results = ActiveRecord::Base.connection.execute(sql)
    
    # Convertir les résultats en un tableau de hachages pour chaque utilisateur
    result_hashes = results.map do |result|
      {
        username: result[0],
        wins_count: result[1],
        submissions_participation_rate: result[2].to_f.round(2),
        contests_count: result[3],
        likes_received_count: result[4],
        winrate: result[5].to_f.round(2)
      }
    end
    
    result_hashes
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
