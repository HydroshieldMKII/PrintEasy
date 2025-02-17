class Api::ContestController < ApplicationController
    def index
        @contests = Contest.all
        render json: {contests: @contests.as_json(methods: :image_url), errors: {}}, status: :ok
    end
    
    def create
        @contest = Contest.new(contest_params)
        if @contest.save
            render json: {contests: @contests, errors: {}}, status: :created
        else
            render json: {errors: @contest.errors.as_json}, status: :unprocessable_entity
        end
    end
    
    def update
        @contest = Contest.find(params[:id])
        if @contest.update(contest_params)
            render json: {contests: @contest, errors: {}}, status: :ok
        else
            render json: {errors: @contest.errors.as_json}, status: :unprocessable_entity
        end
    end
    
    def destroy
        @contest = Contest.find(params[:id])
        @contest.soft_delete
        render json: {contests: @contest, errors: {}}, status: :ok
    end
    
    private
    def contest_params
        params.require(:contest).permit(:theme, :description, :submission_limit, :start_at, :end_at, :image)
    end
end
