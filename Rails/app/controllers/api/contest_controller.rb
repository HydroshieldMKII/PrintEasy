class Api::ContestController < ApplicationController
    before_action :is_admin?, only: [:create, :update, :destroy]

    def index
        @contests = Contest.all

        contests_with_status = @contests.map do |contest|
            contest_data = contest.as_json(methods: :image_url).merge(finished: contest.end_at.present? && contest.end_at < Time.current)
            top_submission = contest.submissions.left_joins(:likes).group(:id).order('COUNT(likes.id) DESC, submissions.created_at ASC').first
            contest_data[:winner_user] = top_submission ? top_submission.user.as_json : nil
            contest_data
        end
        
        contests_with_status.sort_by! { |contest| [contest[:finished] ? 1 : 0, contest[:start_at]] }

        render json: {contests: contests_with_status, errors: {}}, status: :ok
    end

    def show
        @contest = Contest.find(params[:id]) rescue nil

        if @contest
            render json: {contest: @contest.as_json(methods: :image_url), errors: {}}, status: :ok
        else
            render json: {errors: {contest: ["Contest not found"]} }, status: :not_found
        end
    end

    def create
        @contest = Contest.new(contest_params)
        
        if @contest.save
            render json: {contest: @contest.as_json(methods: :image_url), errors: {}}, status: :created
        else
            render json: {errors: @contest.errors.as_json}, status: :unprocessable_entity
        end
    end
    
    def update
        @contest = Contest.find(params[:id]) rescue nil

        if !@contest.nil?
            if @contest.update(contest_params)
                render json: {contest: @contest.as_json(methods: :image_url), errors: {}}, status: :ok
            else
                render json: {errors: @contest.errors.as_json}, status: :unprocessable_entity
            end
        else
            render json: {errors: {contest: ["Contest not found"]} }, status: :not_found
        end
    end
    
    def destroy
        @contest = Contest.find(params[:id]) rescue nil

        if !@contest.nil?
            @contest.soft_delete
            render json: {contest: @contest, errors: {}}, status: :ok
        else
            render json: {errors: {contest: ["Contest not found"]} }, status: :not_found
        end
    end
    
    private
    def is_admin?
        if current_user && !current_user.is_admin
            render json: {errors: {contest: ["You must be an admin to perform this action"]}}, status: :unauthorized
        end
    end

    def contest_params
        params.require(:contest).permit(:theme, :description, :submission_limit, :start_at, :end_at, :image)
    end
end
