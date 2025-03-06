# frozen_string_literal: true

module Api
  class RequestController < AuthenticatedController
    before_action :set_request, only: %i[update destroy]

    def index
      @requests = Request.fetch_for_user(params)
      render Request.format_response(@requests)
    end

    def show
      @request = Request.viewable_by_user.find(params[:id])
      if @request
        render Request.format_response(@request)
      else
        render json: { request: {}, errors: @request.errors }, status: :unprocessable_entity
      end
    end

    def create
      request = current_user.requests.new(request_params)

      if request.save
        render Request.format_response(request, status: :created)
      else
        render json: { request: {}, errors: request.errors }, status: :unprocessable_entity
      end
    end

    def update
      if @request.update(request_params)
        render Request.format_response(@request)
      else
        render json: { request: {}, errors: @request.errors }, status: :unprocessable_entity
      end
    end

    def destroy
      if @request.destroy
        render json: { request: @request, errors: {} }
      else
        render json: { request: {}, errors: @request.errors }, status: :unprocessable_entity
      end
    end

    private

    def set_request
      @request = current_user.requests.find(params[:id])
    end

    def request_params
      params.require(:request).permit(:name, :comment, :target_date, :budget, :stl_file,
                                      preset_requests_attributes: %i[id color_id filament_id printer_id print_quality _destroy])
    end
  end
end
