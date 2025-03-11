# frozen_string_literal: true
module Api
  class RequestController < AuthenticatedController
    before_action :set_request, only: %i[update destroy]
    
    def index
      @requests = Request.fetch_for_user(params)
      render format_response(@requests)
    end
    
    def show
      @request = Request.viewable_by_user.find(params[:id])
      if @request
        render format_response(@request)
      else
        render json: { request: {}, errors: @request.errors }, status: :unprocessable_entity
      end
    end
    
    def create
      request = current_user.requests.new(request_params)
      if request.save
        render format_response(request, status: :created)
      else
        render json: { request: {}, errors: request.errors }, status: :unprocessable_entity
      end
    end
    
    def update
      if @request.update(request_params)
        render format_response(@request)
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
    
    def serialize_request(request)
      request.as_json(
        except: %i[user_id created_at updated_at],
        include: {
          preset_requests: {
            except: %i[request_id color_id filament_id printer_id],
            include: {
              color: { only: %i[id name] },
              filament: { only: %i[id name] },
              printer: { only: %i[id model] }
            },
            methods: [:matching_offer_by_current_user?]
          },
          user: {
            only: %i[id username],
            include: {
              country: { only: %i[name] }
            }
          }
        },
        methods: %i[stl_file_url offer_made? accepted_at]
      )
    end
    
    def serialize_collection(requests)
      requests.as_json(
        except: %i[user_id created_at updated_at],
        include: {
          preset_requests: {
            except: %i[request_id color_id filament_id printer_id],
            include: {
              color: { only: %i[id name] },
              filament: { only: %i[id name] },
              printer: { only: %i[id model] }
            },
            methods: [:matching_offer_by_current_user?]
          },
          user: {
            only: %i[id username],
            include: {
              country: { only: %i[name] }
            }
          }
        },
        methods: %i[stl_file_url offer_made? accepted_at]
      )
    end
    
    def format_response(resource, status: :ok)
      has_printer = Current.user.printers.exists?
      
      request_data = if resource.is_a?(Request)
                       serialize_request(resource)
                     else
                       serialize_collection(resource)
                     end
      
      {
        json: {
          request: request_data,
          has_printer: has_printer,
          errors: {}
        },
        status: status
      }
    end
  end
end