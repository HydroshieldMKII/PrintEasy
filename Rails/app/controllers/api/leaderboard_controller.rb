module Api
    class LeaderboardController < AuthenticatedController
        def index
            @users = User.all

            render json: {
                 leaderboard: @users.as_json(
                    only: %i[username],
                    methods: %i[likes_received_count contests_count won_contests winrate submissions_participation_rate] 
                )
            }, status: :ok
        end
    end
end