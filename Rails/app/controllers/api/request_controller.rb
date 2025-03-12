# frozen_string_literal: true
module Api
  class RequestController < AuthenticatedController
    before_action :set_request, only: %i[update destroy]
   
    def index
      case params[:type]
      when 'all', 'mine'
        @requests = Request.fetch_for_user(params)
        render format_response(@requests)
      when 'stats'
        stats = Request.fetch_stats_for_user
        render json: { stats: stats }
      else
        render json: { request: {}, errors: { type: ["Unknown type: #{params[:type]}"] } }, status: :unprocessable_entity
      end
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
   
    def ordered_preset_requests(request)
      request.preset_requests
             .joins(:printer)
             .joins(:filament)
             .joins(:color)
             .order('printers.model ASC, filaments.name ASC, colors.name ASC, preset_requests.print_quality ASC')
    end
   
    def serialize_request(request)
      sorted_preset_requests = ordered_preset_requests(request)
      
      request_json = request.as_json(
        except: %i[user_id created_at updated_at],
        include: {
          user: {
            only: %i[id username],
            include: {
              country: { only: %i[name] }
            }
          }
        },
        methods: %i[stl_file_url offer_made? accepted_at]
      )
      
      request_json['preset_requests'] = sorted_preset_requests.map do |pr|
        pr_json = pr.as_json(
          except: %i[request_id color_id filament_id printer_id],
          methods: [:matching_offer_by_current_user?]
        )
        
        pr_json['color'] = pr.color.as_json(only: %i[id name]) if pr.color
        pr_json['filament'] = pr.filament.as_json(only: %i[id name]) if pr.filament
        pr_json['printer'] = pr.printer.as_json(only: %i[id model]) if pr.printer
        
        pr_json
      end
      
      request_json
    end
   
    def serialize_collection(requests)
      requests.map { |request| serialize_request(request) }
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