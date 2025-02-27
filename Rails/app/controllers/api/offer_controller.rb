class Api::OfferController < AuthenticatedController
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

    def index
      offers = Offer.all
      render_offers(filter_offers(offers))
    end
  
    def show
      offer = current_user.offers.find(params[:id])
      render_offers(offer)
    end
  
    def create
      offer = Offer.new(offer_params)
      if offer.save
        render json: { offer: offer, errors: {} }, status: :created
      else
        render json: { errors: offer.errors }, status: :unprocessable_entity
      end
    end
  
    def update
      offer = current_user.offers.find(params[:id])
      valid = true

      if offer.printer_user.user != current_user
        valid = false
        offer.errors.add(:offer, 'You are not allowed to update this offer')
      end

      if offer.cancelled_at
        valid = false
        offer.errors.add(:offer, 'Offer already rejected. Cannot update')
      end

      if Order.find_by(offer_id: offer.id)
        valid = false
        offer.errors.add(:offer, 'Offer already accepted. Cannot update')
      end

      if valid && offer.update(offer_params)
        render json: { offer: offer, errors: {} }, status: :ok
      else
        render json: { errors: offer.errors }, status: :unprocessable_entity
      end
    end
  
    def destroy
      offer = current_user.offers.find(params[:id])
      valid = true

      if offer.printer_user.user != current_user
        valid = false
        offer.errors.add(:offer, 'You are not allowed to delete this offer')
      end

      if Order.find_by(offer_id: offer.id)
        valid = false
        offer.errors.add(:offer, 'Offer already accepted. Cannot delete')
      end

      if offer.cancelled_at
        valid = false
        offer.errors.add(:offer, 'Offer already rejected. Cannot delete')
      end

      if valid && offer.destroy
        render json: { offer: offer, errors: {} }, status: :ok
      else
        render json: { errors: { offer: offer.errors } }, status: :unprocessable_entity
      end
    end

    def reject
      offer = Offer.find(params[:id])
      valid = true

      if offer.request.user != current_user
        offer.errors.add(:offer, 'You are not allowed to reject this offer')
        valid = false
      end

      if Order.find_by(offer_id: offer.id)
        offer.errors.add(:offer, 'Request already accepted. Cannot reject')
        valid = false
      end

      if offer.cancelled_at
        offer.errors.add(:offer, 'Offer already rejected')
        valid = false
      end

      if valid
        offer.update_column(:cancelled_at, Time.now)
        render json: { offer: offer, errors: {} }, status: :ok
      else
        render json: { errors: offer.errors }, status: :unprocessable_entity
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
      when 'all' # Offers received on my requests
        # Filtrer les offres NE faisant PAS partie d'une request acceptée
        accepted_requests = Order.joins(:offer).pluck(:request_id).uniq
        offers = offers.where.not(id: Order.pluck(:offer_id)).where.not(request_id: accepted_requests)
        offers.where(request_id: current_user.requests.pluck(:id)).where.not(id: Order.pluck(:offer_id)).distinct
      when 'mine' # Offers sent to another user's requests
        offers.where(printer_user_id: current_user.printer_user.pluck(:id)).where.not(id: Order.pluck(:offer_id)).distinct
      else
        []
      end
    end
  
    def offer_params
      params.require(:offer).permit(:request_id, :printer_user_id, :color_id, :filament_id, :price, :print_quality, :target_date)
    end

    def record_not_found
      render json: { errors: { offer: 'Offer not found' } }, status: :not_found
    end
  end
  