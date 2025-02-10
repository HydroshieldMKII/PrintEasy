# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]
  # before_action :sign_in_params, only: [:create]
  # before_action :check_session, only: [:create]

  # GET /users/sign_in
  # def new
  #   super
  # end

  # POST /users/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)
    render json: { message: "User signed in", user: current_user }, status: 200
  end

  # DELETE /users/sign_out
  def destroy
    sign_out(current_user)
    render json: { message: "User signed out" }, status: 200
  end

  protected

  def auth_options
    { scope: resource_name, recall: "#{controller_path}#new" }
  end

  def sign_in_params
    params.require(:user).permit(:username, :password)
  end

  def check_session
    if user_signed_in?
      render json: { message: "User is already signed in", user: current_user }, status: 200
    end
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
