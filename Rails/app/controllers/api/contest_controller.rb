# frozen_string_literal: true

module Api
  class ContestController < AuthenticatedController
    before_action :is_admin?, only: %i[create update destroy]

    def index
      @contests = Contest.contests_order(current_user)

      render json: { contests: @contests.as_json(methods: %i[image_url finished? started? winner_user]), errors: {} }, status: :ok
    end

    def show
      @contest = Contest.find(params[:id])

      contest_data = @contest.as_json(methods: %i[image_url finished? started?])
      top_submission = @contest.submissions.left_joins(:likes).group(:id)
                               .order('COUNT(likes.id) DESC, submissions.created_at ASC').first
      contest_data[:winner_user] = top_submission&.user&.as_json

      render json: { contest: contest_data, errors: {} }, status: :ok
    end

    def create
      @contest = Contest.new(contest_params)

      if @contest.save
        render json: { contest: @contest.as_json(methods: :image_url), errors: {} }, status: :created
      else
        render json: { errors: @contest.errors.as_json }, status: :unprocessable_entity
      end
    end

    def update
      @contest = Contest.find(params[:id])

      if @contest.update(contest_params)
        render json: { contest: @contest.as_json(methods: :image_url), errors: {} }, status: :ok
      else
        render json: { errors: @contest.errors.as_json }, status: :unprocessable_entity
      end
    end

    def destroy
      @contest = Contest.find(params[:id])

      @contest.soft_delete
      render json: { contest: @contest, errors: {} }, status: :ok
    end

    private

    def is_admin?
      return unless current_user && !current_user.is_admin

      render json: { errors: { contest: ['You must be an admin to perform this action'] } }, status: :unauthorized
    end

    def contest_params
      params.require(:contest).permit(:theme, :description, :submission_limit, :start_at, :end_at, :image)
    end
  end
end
