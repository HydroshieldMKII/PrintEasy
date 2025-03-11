# frozen_string_literal: true

class Like < ApplicationRecord
  belongs_to :user
  belongs_to :submission

  validates :user_id, uniqueness: { scope: :submission_id }

  def self.liked?(user, submission)
    Like.find_by(user: user, submission: submission)
  end
end
