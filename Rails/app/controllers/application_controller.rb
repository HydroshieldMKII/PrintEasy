class ApplicationController < ActionController::API
    rescue_from ActionController::ParameterMissing do |e|
        render json: {errors: {base: [e.message]}}, status: :unprocessable_entity
    end
end
