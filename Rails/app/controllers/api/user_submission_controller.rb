class Api::UserSubmissionController < ApplicationController
    def index
        @contest = Contest.find(submission_params[:contest_id])

        @submissions = @contest.submissions.includes(:likes, :user)

        @users_with_submissions = @submissions.group_by(&:user).map do |user, user_submissions|
          {
            user: user.as_json,
            submissions: user_submissions.as_json(include: :likes, methods: [:image_url, :stl_url])
          }
        end
      
        @users_with_submissions.sort_by! { |user| user[:username] }
      
        render json: { submissions: @users_with_submissions }, status: :ok
    end

    def show
        @submission = Submission.find(params[:id])
        
        @user = @submission.user

        render json: {submission: @submission.as_json(include: :likes, methods: [:stl_url, :image_url]), user: @user.as_json}, status: :ok
    end

    private

    def submission_params
        params.require(:submission).permit(:id, :user_id, :contest_id, :name, :description, :created_at, :updated_at, files: [])
    end
end
