# frozen_string_literal: true

module Api
  class RequestController < AuthenticatedController
    rescue_from ActiveRecord::RecordNotUnique, with: :handle_record_not_unique
    before_action :set_request, only: %i[update destroy]

    def index
      @requests = Request.fetch_for_user(params)
      render_requests(@requests)
    end

    def show
      @request = Request.find(params[:id])

      if @request.viewable_by_user?
        render_requests(@request)
      else
        render json: { request: {}, errors: @request.errors }, status: :unprocessable_entity
      end
    end

    def create
      request = Request.new(request_params)
      request.user = current_user

      if request.save
        render_requests(request, status: :created)
      else
        render json: { request: {}, errors: request.errors }, status: :unprocessable_entity
      end
    end

    def update
      if @request.update(request_params)
        render_requests(@request)
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

    def render_requests(resource, status: :ok)
      has_printer = current_user.printers.exists?

      request_data = if resource.is_a?(Request)
                       resource.serialize
                     else
                       resource.as_json(
                         except: %i[user_id created_at updated_at],
                         include: {
                           preset_requests: {
                             except: %i[request_id color_id filament_id printer_id],
                             include: {
                               color: { only: %i[id name] },
                               filament: { only: %i[id name] },
                               printer: { only: %i[id model] }
                             }
                           },
                           user: {
                             only: %i[id username],
                             include: {
                               country: { only: %i[name] }
                             }
                           }
                         },
                         methods: %i[stl_file_url has_offer_made? accepted_at]
                       )
                     end

      render json: {
        request: request_data,
        has_printer: has_printer,
        errors: {}
      }, status: status
    end

    def handle_record_not_unique(_exception)
      render json: { request: {},
                     errors: { preset_requests: ['Duplicate preset exists in the request'] } },
             status: :unprocessable_entity
    end
  end
end
