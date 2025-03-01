# frozen_string_literal: true

module Api
  class UserSubmissionController < AuthenticatedController
    def index
      @contest = Contest.find(submission_params[:contest_id])
      @users_with_submissions = @contest.users_with_submissions(current_user)
      
      render json: { submissions: @users_with_submissions }, status: :ok
    end

    def show
      @submission = Submission.find(params[:id])

      @user = @submission.user

      render json: { submission: @submission.as_json(include: :likes, methods: %i[stl_url image_url]), user: @user.as_json },
             status: :ok
    end

    private

    def submission_params
      params.require(:submission).permit(:id, :user_id, :contest_id, :name, :description, :created_at, :updated_at)
    end
  end
end
