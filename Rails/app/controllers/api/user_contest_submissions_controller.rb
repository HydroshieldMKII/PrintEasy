# frozen_string_literal: true

module Api
  class UserContestSubmissionsController < AuthenticatedController
    def index
      @contests = Contest.joins(:submissions).where(submissions: { user_id: current_user.id }).distinct

      contests_with_submissions = @contests.map do |contest|
        contest_data = contest.as_json(methods: %i[image_url finished?])

        if contest_data['finished?']
          top_submission = contest.submissions.left_joins(:likes)
                                  .group(:id)
                                  .order('COUNT(likes.id) DESC, submissions.created_at ASC')
                                  .first
          contest_data[:winner_user] = top_submission&.user&.as_json
        else
          contest_data[:winner_user] = nil
        end

        {
          contest: contest_data,
          submissions: contest.submissions.where(user_id: current_user.id)
                              .as_json(include: :likes, methods: %i[image_url stl_url])
        }
      end

      render json: { contests: contests_with_submissions }, status: :ok
    end
  end
end
