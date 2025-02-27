# frozen_string_literal: true

class ApplicationController < ActionController::API
  rescue_from ActionController::ParameterMissing do |e|
    render json: { errors: { base: [e.message] } }, status: :unprocessable_entity
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: { errors: { base: [e.message] } }, status: :not_found
  end

  rescue_from NoMethodError do |e|
    render json: { errors: { base: [e.message] } }, status: :internal_server_error
  end
end
