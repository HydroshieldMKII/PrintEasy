class Api::ContestController < ApplicationController
    def index
        @contests = Contest.all
        render json: @contests
    end
    
    def create
        @contest = Contest.new(contest_params)
        if @contest.save
            render json: @contest
        else
            render json: {errors: @contest.errors.as_json}, status: :unprocessable_entity
        end
    end
    
    def show
        @contest = Contest.find(params[:id])
        render json: @contest
    end
    
    def update
        @contest = Contest.find(params[:id])
        if @contest.update(contest_params)
            render json: @contest
        else
            render json: {errors: @contest.errors.as_json}, status: :unprocessable_entity
        end
    end
    
    def destroy
        @contest = Contest.find(params[:id])
        @contest.destroy
        render json: {message: "Contest Deleted"}
    end
    
    private
    def contest_params
        params.require(:contest).permit(:theme, :description, :submission_limit, :start_at, :end_at, :image)
    end
end
