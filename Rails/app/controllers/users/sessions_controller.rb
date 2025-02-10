# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]
  before_action :sign_in_params, only: [:create]
  # before_action :check_session, only: [:create]

  # GET /users/sign_in
  # def new
  #   super
  # end

  # POST /users/sign_in
  def create
    @user = User.find_by(username: sign_in_params[:username])

    if @user && @user.valid_password?(sign_in_params[:password])
      # sign_in(@user)
      render json: { message: "User signed in", user: @user }, status: 200
    else
      render json: { message: "Invalid username or password" }, status: 400
    end
  end

  # DELETE /users/sign_out
  def destroy
    sign_out(current_user)
    render json: { message: "User signed out" }, status: 200
  end

  protected

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
