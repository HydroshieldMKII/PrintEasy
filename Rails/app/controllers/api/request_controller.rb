class Api::RequestController < ApplicationController
    before_action :authenticate_user!
    before_action :index_params, only: :index

    # GET /requests
    def index
        # debugger
        @requests = case params[:type]
                    when 'all'
                      Request.where.not(user: current_user)
                    when 'my'
                      Request.where(user: current_user)
                    else
                      Request.all
                    end
    
        # Apply search filter
        if params[:search].present?
          search_term = "%#{params[:search]}%"
          @requests = @requests.where("name LIKE ?", search_term)
        end
    
        # Apply filtering
        case params[:filter]
        when 'owned-printer'
          @requests = @requests.joins(:preset_requests).where(preset_requests: { printer_id: current_user.printer_users.pluck(:printer_id) })
        when 'country'
          @requests = @requests.joins(:user).where(users: { country_id: current_user.country_id })
        end
    
        # Apply sorting
        if params[:sortCategory].present? && params[:sort].present?
          sort_column = case params[:sortCategory]
                        when 'name' then 'name'
                        when 'date' then 'target_date'
                        when 'budget' then 'budget'
                        when 'country' then 'users.country_id'
                        else 'created_at' # default
                        end
          sort_direction = params[:sort] == 'asc' ? 'ASC' : 'DESC'
          @requests = @requests.joins(:user).order("#{sort_column} #{sort_direction}")
        end
    
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
      params.permit(:type, :search, :filter, :sortCategory, :sort)
    end

  end
  