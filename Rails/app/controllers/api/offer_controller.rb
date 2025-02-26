class Api::OfferController < AuthenticatedController
    def index
      offers = Offer.all
      render_offers(filter_offers(offers))
    end
  
    def show
      offer = Offer.find(params[:id])
      if offer.printer_user.user != current_user
        render json: { offer: {}, errors: { offer: ['You are not allowed to view this offer'] } }, status: :forbidden
        return
      end
  
      render_offers(offer)
    end
  
    def create
      offer = Offer.new(offer_params)
      if offer.save
        render json: offer
      else
        render json: { errors: offer.errors }, status: :unprocessable_entity
      end
    end
  
    def update
      offer = Offer.find(params[:id])
      if offer.update(offer_params)
        render json: offer
      else
        render json: { errors: offer.errors }, status: :unprocessable_entity
      end
    end
  
    def destroy
      if Offer.find(params[:id]).destroy
        render json: { errors: {} }, status: :ok
      else
        render json: { errors: { offer: offer.errors } }, status: :unprocessable_entity
      end
    end
  
    private
  
    def render_offers(resource, status: :ok)
      if resource.is_a?(Offer)
        render json: { offer: resource.as_json(
          except: %i[request_id printer_user_id created_at updated_at color_id filament_id],
          include: {
            printer_user: {
              only: %i[id],
              include: {
                user: {
                  only: %i[id username]
                },
                printer: {
                  only: %i[id model]
                }
              }
            },
            color: {},
            filament: {}
          }
        ), errors: {} }, status: status
      else
        grouped = resource.group_by(&:request)
        requests = grouped.map do |request_obj, offers|
          request_obj.as_json(
            except: %i[user_id created_at updated_at],
            include: {
              user: {
                only: %i[id username],
                include: {
                  country: {
                    only: %i[id name]
                  }
                }
              }
            }
          ).merge(
            offers: offers.as_json(
              except: %i[request_id printer_user_id created_at updated_at color_id filament_id],
              include: {
                printer_user: {
                  only: %i[id],
                  include: {
                    user: {
                      only: %i[id username]
                    },
                    printer: {
                      only: %i[id model]
                    }
                  }
                },
                color: {},
                filament: {}
              }
            )
          )
        end
        render json: { requests: requests, errors: {} }, status: status
      end
    end
  
    def filter_offers(offers)
      case params[:type]
      when 'all' # Offers received
        offers.where(request_id: current_user.requests.pluck(:id)).where.not(id: Order.pluck(:offer_id)).distinct
      when 'mine' # Offers sent (pending)
        offers.where(printer_user_id: current_user.printer_user.pluck(:id)).where.not(id: Order.pluck(:offer_id)).distinct
      else
      []
      end
    end
  
    def offer_params
      params.require(:offer).permit(:request_id, :printer_user_id, :color_id, :filament_id, :price, :print_quality, :target_date)
    end
    
  end
  