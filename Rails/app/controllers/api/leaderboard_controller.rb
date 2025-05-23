# frozen_string_literal: true

module Api
  class LeaderboardController < AuthenticatedController
    def index
      @leaderboard = User.stats(category: params[:category], direction: params[:direction],
                                start_date: params[:start_date], end_date: params[:end_date])

      render json: { leaderboard: @leaderboard }, status: :ok
    end
  end
end
