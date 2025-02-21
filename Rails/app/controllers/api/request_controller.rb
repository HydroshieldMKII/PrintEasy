class Api::RequestController < AuthenticatedController
  rescue_from ActiveRecord::RecordNotUnique, with: :handle_record_not_unique
  before_action :index_params, only: :index
  before_action :show_params, only: :show
  before_action :create_params, only: :create
  before_action :update_params, only: :update
  before_action :stl_file_extension?, only: %i[create update]

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
    # debugger
    @request = Request.new(create_params)
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
    valid = true
    
    if @request.user != current_user
      render json: { request: {}, errors: { request: ['You are not allowed to update this request'] } }, status: :forbidden
      return
    end

    if update_params[:target_date].present? && update_params[:target_date].to_date.strftime("%a, %d %b %Y") != @request.target_date && update_params[:target_date].to_date < Date.today
      # debugger
      valid = false
      @request.errors.add(:target_date, 'must be greater than today')
    end

    #Check if the request has any offers accepted
    if @request.has_offer_accepted?
      valid = false
      @request.errors.add(:base, 'Cannot update request with accepted offers')
    end

    update_params.delete(:preset_requests_attributes) if @request.has_offer_made?

    if valid && @request.update(update_params)
      render_request(@request)
    else
      # debugger
      render json: { request: {}, errors: @request.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /requests/:id
  def destroy
    @request = Request.find(params[:id])

    if @request.user != current_user
      render json: { request: {}, errors: { request: ['You are not allowed to delete this request'] } }, status: :forbidden
      return
    end

    @request.destroy
    render json: { request: @request, errors: {} }
  end

  private

  def fetch_requests
    case params[:type]
    when 'all'
      # Exclude requests that have any accepted offers.
      accepted_request_ids = Request.joins(offers: { order: :order_status })
                                    .where(order_status: { status_name: 'Accepted' })
                                    .select(:id)
  
      requests = Request.includes(:user, preset_requests: %i[color filament printer])
                        .where.not(user: current_user)
                        .where.not(id: accepted_request_ids)
    when 'my'
      requests = Request.includes(:user, preset_requests: %i[color filament printer])
                        .where(user: current_user)
    else
      return []
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
        methods: %i[stl_file_url has_offer_made? has_offer_accepted?]
      ),
      errors: resource.respond_to?(:errors) ? resource.errors : {}
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
    params.require(:request).permit(:name, :comment, :target_date, :budget, :stl_file, preset_requests_attributes: %i[color_id filament_id printer_id print_quality])
  end

  def update_params
    params.require(:request).permit(:name, :comment, :target_date, :budget, :stl_file, preset_requests_attributes: %i[id color_id filament_id printer_id print_quality _destroy])
  end

  def stl_file_extension?
    if params[:request][:stl_file].present?
      extension = File.extname(params[:request][:stl_file]&.path)
      unless extension == '.stl'
        render json: { request: {}, errors: { stl_file: ['must have .stl extension'] } }, status: :unprocessable_entity
      end
    end
  end

  def handle_record_not_unique(exception)
    render json: { request: {}, errors: { preset_requests: ['Duplicate preset exists in the request'] } },
           status: :unprocessable_entity
  end
end
