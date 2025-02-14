class Like < ApplicationRecord
  belongs_to :user
  belongs_to :submission

  validates :user_id, uniqueness: { scope: :submission_id }

  def self.like(user, submission)
    Like.create(user: user, submission: submission)
  end

  def self.unlike(user, submission)
    like = Like.find_by(user: user, submission: submission)
    like.destroy if like
  end

  def self.liked?(user, submission)
    Like.find_by(user: user, submission: submission)
  end
end
