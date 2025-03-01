# frozen_string_literal: true

module Api
  class UserContestSubmissionsController < AuthenticatedController
    def index
      contests_with_submissions = current_user.user_contests_submissions

      render json: { contests: contests_with_submissions }, status: :ok
    end
  end
end
