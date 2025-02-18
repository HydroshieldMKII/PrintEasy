class Api::RequestController < ApplicationController
    before_action :authenticate_user!
    before_action :index_params, only: :index
  
    # GET /requests
    def index
      @requests = Request.includes(:user, preset_requests: [:color, :filament, :printer])
  
      # Filter Requests
      case params[:type]
      when 'all'
        @requests = @requests.where.not(user: current_user)
      when 'my'
        @requests = @requests.where(user: current_user)
      end
  
      # Search by name
      if params[:search].present?
        @requests = @requests.where("name ILIKE ?", "%#{params[:search]}%")
      end
  
      # Apply Filters
      if params[:filter] == 'owned-printer'
        @requests = @requests.joins(:preset_requests).where(preset_requests: { printer_id: current_user.printer_ids })
      elsif params[:filter] == 'country'
        @requests = @requests.joins(:user).where(users: { country_id: current_user.country_id })
      end
  
      # Apply Sorting
      if params[:order].present?
        field, direction = params[:order].split('-')
        case field
        when 'name'
          @requests = @requests.order(name: direction)
        when 'date'
          @requests = @requests.order(target_date: direction)
        when 'budget'
          @requests = @requests.order(budget: direction)
        when 'country'
          @requests = @requests.joins(:user).order("users.country_id #{direction}")
        end
      end
  
      # Render JSON response
      render json: {
        requests: @requests.as_json(
          except: %i[user_id created_at updated_at],
          include: {
            preset_requests: {
              except: %i[id request_id color_id filament_id printer_id],
              include: {
                color: { except: %i[id] },
                filament: { except: %i[id] },
                printer: { except: %i[id] }
              }
            },
            user: { 
              only: %i[id username],
              include: {
                country: { only: %i[name] }
              }
            }
          },
          methods: :stl_file_url
        ),
        errors: {}
      }, status: :ok
    end
  
    private
  
    def index_params
      params.permit(:type, :order, :search, :filter)
    end
  end
  