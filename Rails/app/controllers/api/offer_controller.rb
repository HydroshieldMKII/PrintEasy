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
        Offer.find(params[:id]).destroy
    end
    private

    def render_offers(resource, status: :ok)
        render json: {
            offer: resource.as_json(
                except: %i[request_id printer_user_id created_at updated_at color_id filament_id],
                include: {
                    color: {},
                    filament: {},
                    printer_user: {
                        except: %i[printer_id user_id],
                        include: {
                            user: {
                                except: %i[country_id created_at updated_at is_admin],
                                include: {
                                    country: {}
                                }
                            },
                            printer: {}
                        }
                    },
                    request: {
                        except: %i[user_id created_at updated_at],
                    }
                }
            ),
            errors: resource.respond_to?(:errors) ? resource.errors : {}
        }, status: status
    end

    def filter_offers(offers)
        case params[:type]
        when 'all' #offer received
            offers.where(request_id: current_user.requests.pluck(:id)).distinct
        when 'mine' #offer sent (pending)
            offers.where(printer_user_id: current_user.printer_user.pluck(:id)).distinct
        else
          []
        end
    end
      

    def offer_params
        params.require(:offer).permit(:request_id, :printer_user_id, :color_id, :filament_id, :price)
    end
end