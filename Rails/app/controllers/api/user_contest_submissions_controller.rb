# frozen_string_literal: true

module Api
  class UserContestSubmissionsController < AuthenticatedController
    def index
      @user = User.find(params[:user_id])
      contests_with_submissions = @user.user_contests_submissions

      render json: { contests: contests_with_submissions }, status: :ok
    end
  end
end
