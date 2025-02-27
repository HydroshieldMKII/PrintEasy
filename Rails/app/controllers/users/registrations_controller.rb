# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :sign_up_params, only: [:create]

    # POST /resource
    def create
      build_resource(sign_up_params)

      if resource.save
        handle_successful_signup(resource)
      else
        handle_failed_signup(resource)
      end
    end

    private

    def handle_successful_signup(resource)
      if resource.active_for_authentication?
        sign_up(resource_name, resource)
        render json: { user: current_user.as_json.merge(profile_picture_url: current_user.profile_picture_url), errors: {} },
               status: 200
      else
        expire_data_after_sign_in!
        render json: { errors: resource.errors.as_json }, status: :unprocessable_entity
      end
    end

    def handle_failed_signup(resource)
      clean_up_passwords resource
      set_minimum_password_length
      render json: { errors: resource.errors.as_json }, status: :unprocessable_entity
    end

    def sign_up_params
      params.require(:user).permit(:username, :password, :password_confirmation, :country_id)
    rescue ActionController::ParameterMissing => e
      render json: { errors: { user: [e.message] } }, status: :unprocessable_entity
    end
  end
end
