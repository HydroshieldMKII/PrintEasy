module Api
    class LeaderboardController < ApplicationController
        def index
            @users = User.all

            render json: {
                 leaderboard: @users.as_json(
                    methods: %i[likes_received_count contests_count wins_count winrate submissions_participation_rate] 
                )
            }, status: :ok
        end
    end
end