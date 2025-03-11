module Api
    class LeaderboardController < ApplicationController
        def index
            @leaderboard = User.stats(order_by: params[:order_by], direction: params[:direction], start_date: params[:start_date], end_date: params[:end_date])
            
            render json: { leaderboard: @leaderboard }, status: :ok
        end
    end
end