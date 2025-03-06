module Api
    class UserProfileController < AuthenticatedController
        def show
            user = User.find(params[:id])
            render json: {
                user: user.as_json(
                    except: %i[country_id],
                    include: {
                        country: {only: %i[id name]}, 
                        printer_users: {
                            include: {
                                printer: {},
                                user: {
                                    include: {country: {only: %i[id name]}}
                                }
                            }
                        }
                    },
                    methods: %i[profile_picture_url user_contests_submissions]
                ),
                errors: {}
            }, status: :ok
        end
    end
end