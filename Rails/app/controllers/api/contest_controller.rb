# frozen_string_literal: true

module Api
  class ContestController < AuthenticatedController
    before_action :admin?, only: %i[create update destroy]

    def index
      @contests = Contest.contests_order(current_user, params)

      render json: {
               contests: @contests.as_json(include: :submissions,
                                           methods: %i[image_url finished? started?
                                                       winner_user]), errors: {}
             },
             status: :ok
    end

    def show
      @contest = Contest.find(params[:id])

      render json: {
               contest: @contest.as_json(include: :submissions, methods: %i[image_url finished? started? winner_user]), errors: {}
             },
             status: :ok
    end

    def create
      @contest = Contest.new(contest_params)

      if @contest.save
        render json: {
                 contest: @contest.as_json(include: :submissions,
                                           methods: %i[image_url finished? started?
                                                       winner_user]), errors: {}
               },
               status: :created
      else
        render json: { errors: @contest.errors.as_json }, status: :unprocessable_entity
      end
    end

    def update
      @contest = Contest.find(params[:id])

      if @contest.update(contest_params)
        render json: {
                 contest: @contest.as_json(include: :submissions,
                                           methods: %i[image_url finished? started?
                                                       winner_user]), errors: {}
               },
               status: :ok
      else
        render json: { errors: @contest.errors.as_json }, status: :unprocessable_entity
      end
    end

    def destroy
      @contest = Contest.find(params[:id])
      # deleted = @contest.started? ? @contest.soft_delete : @contest.destroy

      if @contest.destroy
        render json: {
                 contest: @contest.as_json(include: :submissions,
                                           methods: %i[image_url finished? started?
                                                       winner_user]), errors: {}
               },
               status: :ok
      else
        render json: { errors: @contest.errors.as_json }, status: :unprocessable_entity
      end
    end

    private

    def admin?
      return if current_user.is_admin

      render json: { errors: { contest: ['You must be an admin to perform this action'] } }, status: :unauthorized
    end

    def contest_params
      params.require(:contest).permit(:theme, :description, :submission_limit, :start_at, :end_at, :image)
    end
  end
end
