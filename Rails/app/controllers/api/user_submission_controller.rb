class Api::UserSubmissionController < ApplicationController
    def index
        @submissions = Contest.find(submission_params[:contest_id]).submissions

        @users_with_submissions = @submissions.select(:user_id).distinct.map do |user|
            @user = User.find(user.user_id)
            {
                id: @user.id,
                username: @user.username,
                profile_picture: @user.profile_picture_url,
                submissions: @user.submissions.as_json(include: :likes, methods: [:image_url, :stl_url])
            }
        end
        @users_with_submissions.sort_by! { |user| user[:username] }
        render json: {submissions: @users_with_submissions}, status: :ok
    end

    def show
        @submission = Submission.find_by(id: params[:id])
        
        @user = User.find(@submission.user_id)

        render json: {submission: @submission.as_json(include: :likes, methods: [:stl_url, :image_url]), user: @user.as_json}, status: :ok
    end

    private

    def submission_params
        params.require(:submission).permit(:id, :user_id, :contest_id, :name, :description, :created_at, :updated_at, files: [])
    end
end
