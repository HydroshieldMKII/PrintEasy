# frozen_string_literal: true

module Api
  class SubmissionController < AuthenticatedController
    before_action :find_submission, only: %i[show update destroy]

    def index
      @submissions = Contest.find(submission_params[:contest_id]).submissions

      render json: { submissions: @submissions.as_json(include: :likes, methods: %i[stl_url image_url]) }, status: :ok
    end

    def show
      render json: { submission: @submission.as_json(include: :likes, methods: %i[stl_url image_url]) }, status: :ok
    end

    def create
      @submission = current_user.submissions.build(submission_params)

      if @submission.save
        render json: { submission: @submission.as_json(methods: %i[stl_url image_url]), errors: {} }, status: :created
      else
        render json: { errors: @submission.errors.as_json }, status: :unprocessable_entity
      end
    end

    def update
      if @submission.update(submission_params)
        render json: { submission: @submission.as_json(methods: %i[stl_url image_url]), errors: {} }, status: :ok
      else
        render json: { errors: @submission.errors.as_json }, status: :unprocessable_entity
      end
    end

    def destroy
      if @submission.destroy
        render json: { submission: @submission.as_json(include: :likes, methods: %i[stl_url image_url]), errors: {} },
               status: :ok
      else
        render json: { errors: @submission.errors.as_json }, status: :unprocessable_entity
      end
    end

    private

    def find_submission
      @submission = current_user.submissions.find(params[:id])
    end

    def submission_params
      params.require(:submission).permit(:contest_id, :name, :description, :created_at, :updated_at, :stl, :image)
    end
  end
end
