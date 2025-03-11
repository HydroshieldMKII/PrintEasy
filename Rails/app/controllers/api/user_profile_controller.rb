# frozen_string_literal: true
module Api
  class UserProfileController < AuthenticatedController
    def show
      user = User.find(params[:id])
      ordered_printer_users = user.printer_users.includes(:printer, user: :country).order('printers.model')
      
      user_json = user.as_json(
        except: %i[country_id],
        include: {
          country: { only: %i[id name] }
        },
        methods: %i[profile_picture_url user_contests_submissions self_reviews]
      )
      
      user_json['printer_users'] = ordered_printer_users.as_json(
        include: {
          printer: {},
          user: {
            include: { country: { only: %i[id name] } }
          }
        },
        methods: %i[last_used can_update]
      )
      
      render json: {
        user: user_json,
        errors: {}
      }, status: :ok
    end
  end
end