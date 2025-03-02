# frozen_string_literal: true

module Api
  class RequestController < AuthenticatedController
    rescue_from ActiveRecord::RecordNotUnique, with: :handle_record_not_unique
    before_action :set_request, only: %i[show update destroy]

    def index
      @requests = fetch_requests
      render_requests(@requests)
    end

    def show
      if current_user.printers.exists?
        render_requests(@request)
      else
        render json: { request: {}, errors: { request: ['You must have a printer to view request details'] } },
               status: :unprocessable_entity
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
      if resource.is_a?(Request) # Single request
        render json: {
          request: serialize_request(resource),
          has_printer: current_user.printers.exists?,
          errors: {}
        }, status: status
      else # Collection of requests
        render json: {
          request: resource.map { |req| serialize_request(req) },
          has_printer: current_user.printers.exists?,
          errors: {}
        }, status: status
      end
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
      )
    end

    def fetch_requests
      case params[:type]
      when 'all'
        if current_user.printers.exists?
          accepted_requests = Request.joins(offers: { order: :order_status })
                                     .where(order_status: { status_name: 'Accepted' })

          requests = Request.includes(:user, preset_requests: %i[color filament printer])
                            .where.not(user: current_user)
                            .where.not(id: accepted_requests)
        else
          requests = Request.none
        end
      when 'mine'
        requests = current_user.requests.includes(:user, preset_requests: %i[color filament printer])
      else
        requests = Request.none
      end

      requests = requests.where('name LIKE ?', "%#{params[:search]}%") if params[:search].present?
      requests = filter_requests(requests)
      sort_requests(requests)
    end

    def filter_requests(requests)
      case params[:filter]
      when 'owned-printer'
        requests.joins(:preset_requests)
                .where(preset_requests: { printer_id: current_user.printer_user.pluck(:printer_id) }).distinct
      when 'country'
        requests.joins(:user).where(users: { country_id: current_user.country_id }).distinct
      when 'in-progress'
        requests.joins(offers: { order: :order_status }).where(order_status: { status_name: 'Accepted' }).distinct
      else
        requests
      end
    end

    def sort_requests(requests)
      if params[:sortCategory].present? && params[:sort].present?
        sort_column = {
          'name' => 'requests.name',
          'date' => 'target_date',
          'budget' => 'budget',
          'country' => 'users.country_id'
        }.fetch(params[:sortCategory], 'created_at')
        sort_direction = params[:sort] == 'asc' ? 'ASC' : 'DESC'
        return requests.order("#{sort_column} #{sort_direction}")
      end
      requests.order('target_date ASC')
    end

    def handle_record_not_unique(_exception)
      render json: { request: {},
                     errors: { preset_requests: ['Duplicate preset exists in the request'] } },
             status: :unprocessable_entity
    end
  end
end
