class Api::ContestController < ApplicationController
    def index
        @contests = Contest.all
        render json: {contests: @contests.as_json(methods: :image_url), errors: {}}, status: :ok
    end

    def show
        @contest = Contest.find(params[:id]) rescue nil

        if @contest
            render json: {contest: @contest.as_json(methods: :image_url), errors: {}}, status: :ok
        else
            render json: {errors: "Contest not found"}, status: :not_found
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
            render json: {errors: "Contest not found"}, status: :not_found
        end
    end
    
    def destroy
        @contest = Contest.find(params[:id]) rescue nil

        if !@contest.nil?
            @contest.soft_delete
            render json: {contest: @contest, errors: {}}, status: :ok
        else
            render json: {errors: "Contest not found"}, status: :not_found
        end
    end
    
    private
    def contest_params
        params.require(:contest).permit(:theme, :description, :submission_limit, :start_at, :end_at, :image)
    end
end
