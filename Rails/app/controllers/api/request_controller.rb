class Api::RequestController < ApplicationController
    before_action :index_params, only: :index

    # GET /requests
    def index
        if params[:type] == 'all'
            @requests = Request.where.not(user: current_user)
        elsif params[:type] == 'my'
            @requests = Request.where(user: current_user)
        else
            @requests = Request.all
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
      params.permit(:type)
    end

  end
  