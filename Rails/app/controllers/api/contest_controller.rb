# frozen_string_literal: true

module Api
  class ContestController < ApplicationController
    before_action :is_admin?, only: %i[create update destroy]

    def index
      @contests = current_user.is_admin ? Contest.all : Contest.active_for_user(current_user)
      contests_with_status = @contests.map do |contest|
        contest_data = contest.as_json(methods: %i[image_url finished?])

        top_submission = contest.submissions.left_joins(:likes).group(:id).order('COUNT(likes.id) DESC, submissions.created_at ASC').first
        contest_data[:winner_user] = top_submission&.user&.as_json
        contest_data
      end

      contests_with_status.sort_by! do |contest|
        [contest['finished?'] ? 1 : 0, contest['start_at']]
      end

      render json: { contests: contests_with_status, errors: {} }, status: :ok
    end

    def show
      @contest = Contest.find(params[:id])

      contest_data = @contest.as_json(methods: %i[image_url finished?])
      top_submission = @contest.submissions.left_joins(:likes).group(:id).order('COUNT(likes.id) DESC, submissions.created_at ASC').first
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
