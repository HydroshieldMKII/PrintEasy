# frozen_string_literal: true

module Api
  class UserSubmissionController < AuthenticatedController
    def index
      @contest = Contest.find(params[:contest_id])
      @users_with_submissions = @contest.users_with_submissions(current_user)

      render json: { submissions: @users_with_submissions }, status: :ok
    end
  end
end
