class Api::SubmissionController < AuthenticatedController
    before_action :find_submission, only: [:show, :update, :destroy]
    before_action :submission_user, only: [:update, :destroy]
  
    def index
      @submissions = Contest.find(submission_params[:contest_id]).submissions
      # debugger
      # @users_with_submissions = @submissions.select(:user_id).distinct.map do |user|
      #   {
      #     id: user.id,
      #     username: user.username,
      #     profile_picture: user.profile_picture_url,
      #     submissions: user.submissions.as_json(include: :likes, methods: [:stl_url, :image_url])
      #   }
      # end

      render json: {submissions: @submissions.as_json(include: :likes, methods: [:stl_url, :image_url])}, status: :ok
    end
    
    def show
      render json: {submission: @submission.as_json(include: :likes, methods: [:stl_url, :image_url])}, status: :ok
    end
  
    def create
      @submission = Submission.new(submission_params)
      current_user.submissions << @submission

      if @submission.save
        render json: {submission: @submission.as_json(methods: [:stl_url, :image_url]), errors: {}}, status: :created
      else
        render json: { errors: @submission.errors.as_json }, status: :unprocessable_entity
      end
    end
  
    def update
      if @submission.update(submission_params)
        render json: {submission: @submission.as_json(methods: [:stl_url, :image_url]), errors: {}}, status: :ok
      else
        render json: { errors: @submission.errors.as_json }, status: :unprocessable_entity
      end
    end
  
    def destroy
      @submission.destroy
      render json: {submission: @submission.as_json(include: :likes, methods: [:stl_url, :image_url]), errors: {}}, status: :ok
    end
    
    private
    
    def find_submission
      @submission = Submission.find_by(id: params[:id])
      if @submission.nil?
        render json: { errors: { submission: ["Submission not found"] } }, status: :not_found
      end
    end
  
    def submission_user
      return if @submission.nil?

      unless current_user.id == @submission.user_id
        render json: { errors: {
          user: ["You are not authorized to perform this action"]
        } }, status: :unauthorized
      end
    end
  
    def submission_params
      params.require(:submission).permit(:id, :contest_id, :name, :description, :created_at, :updated_at, files: [])
    end
  end
  