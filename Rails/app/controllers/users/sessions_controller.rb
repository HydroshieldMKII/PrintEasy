# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # POST /users/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)
    render json: { user: current_user, errors: {} }, status: 200
  end

  # DELETE /users/sign_out
  def destroy
    sign_out(current_user)
    render json: { errors: {} }, status: 200
  end

  protected

  # def auth_options
  #   { scope: resource_name, recall: "#{controller_path}#new" }
  # end

  def sign_in_params
    params.require(:user).permit(:username, :password)
  end
end
