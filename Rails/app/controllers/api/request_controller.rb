class Api::RequestController < ApplicationController
  before_action :authenticate_user!
  before_action :index_params, only: :index
  before_action :show_params, only: :show
  before_action :create_params, only: :create

  # GET /requests
  def index
    @requests = fetch_requests
    render_request(@requests)
  end

  # GET /requests/:id
  def show
    @request = Request.includes(:user, preset_requests: %i[color filament printer]).find(params[:id])
    render_request(@request)
  end

  # POST /requests
  def create
    @request = Request.new(request_params)
    @request.user = current_user

    if @request.save
      render_request(@request, status: :created)
    else
      render json: { request: {}, errors: @request.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /requests/:id
  def update
    @request = Request.includes(:user, preset_requests: %i[color filament printer]).find(params[:id])
    
    if @request.user != current_user
      render json: { request: {}, errors: { request: ['You are not allowed to update this request'] } }, status: :unauthorized
      return
    end

    if @request.update(request_params)
      render_request(@request)
    else
      render json: { request: {}, errors: @request.errors }, status: :unprocessable_entity
    end
  end

  private

  def fetch_requests
    requests = case params[:type]
               when 'all'
                 Request.includes(:user, preset_requests: %i[color filament printer]).where.not(user: current_user)
               when 'my'
                 Request.includes(:user, preset_requests: %i[color filament printer]).where(user: current_user)
               else
                 Request.none
               end

    requests = requests.where("name LIKE ?", "%#{params[:search]}%") if params[:search].present?
    requests = filter_requests(requests)
    requests = sort_requests(requests)

    requests
  end

  def render_request(resource, status: :ok)
    render json: {
      request: resource.as_json(
        except: %i[user_id created_at updated_at],
        include: {
          preset_requests: {
            except: %i[id request_id color_id filament_id printer_id],
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
        methods: :stl_file_url
      ),
      errors: {}
    }, status: status
  end

  def filter_requests(requests)
    case params[:filter]
    when 'owned-printer' 
      requests.joins(:preset_requests).where(preset_requests: { printer_id: current_user.printer_users.pluck(:printer_id) }).distinct #https://apidock.com/rails/ActiveRecord/Calculations/pluck
    when 'country'
      requests.joins(:user).where(users: { country_id: current_user.country_id }).distinct
    else
      requests
    end
  end

  def sort_requests(requests)
    return requests unless params[:sortCategory].present? && params[:sort].present?

    sort_column = case params[:sortCategory]
                  when 'name' then 'name'
                  when 'date' then 'target_date'
                  when 'budget' then 'budget'
                  when 'country' then 'users.country_id'
                  else 'created_at'
                  end
    sort_direction = params[:sort] == 'asc' ? 'ASC' : 'DESC'
    requests.order("#{sort_column} #{sort_direction}")
  end

  def index_params
    params.permit(:type, :search, :filter, :sortCategory, :sort).require(:type)
  end

  def show_params
    params.permit(:id).require(:id)
  end

  def create_params
    params.permit(:name, :description, :target_date, :budget, :stl_file, preset_requests_attributes: %i[color_id filament_id printer_id]).require(:request)
  end
end
