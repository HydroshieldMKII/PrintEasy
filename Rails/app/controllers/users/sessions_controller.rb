# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # POST /users/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)
    debugger
    render json: { user: current_user.as_json.merge(profile_picture_url: current_user.profile_picture_url, country_name: current_user.country.name), errors: {} }, status: 200
  end

  # DELETE /users/sign_out
  def destroy
    sign_out(resource_name)
    render json: { errors: {} }, status: 200
  end

  private

  def respond_to_on_destroy
    render json: { errors: "You need to sign in or sign up before continuing." }, status: 401
  end
end
