class Api::RequestController < ApplicationController
    # GET /requests
    def index
      @requests = Request.all
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
  end
  