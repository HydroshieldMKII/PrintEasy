module Api
    class LeaderboardController < ApplicationController
        def index
            @leaderboard = User.stats(order_by: params[:order_by], direction: params[:direction], year: params[:year])
            
            render json: { leaderboard: @leaderboard }, status: :ok
        end
    end
end