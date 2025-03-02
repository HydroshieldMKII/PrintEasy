# frozen_string_literal: true

module Api
  class OfferController < AuthenticatedController
    before_action :set_offer, only: %i[show update destroy]

    def index
      offers = filter_offers
      offers = offers.sort_by(&:target_date)
      render_offers(offers)
    end

    def show
      render_offers(@offer)
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
      if @offer.update(offer_params)
        render json: { offer: @offer, errors: {} }, status: :ok
      else
        render json: { errors: @offer.errors }, status: :unprocessable_entity
      end
    end

    def destroy
      if @offer.can_destroy? && @offer.destroy
        render json: { offer: @offer, errors: {} }, status: :ok
      else
        render json: { errors: @offer.errors }, status: :unprocessable_entity
      end
    end

    def reject
      # Find offers by ID, without filtering by user initially
      begin
        offer = Offer.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: {
          errors: {
            base: ["Couldn't find Offer with 'id'=#{params[:id]}"]
          }
        }, status: :not_found
        return
      end

      # Now check if the offer can be rejected by this user
      if offer.can_reject?(current_user) && offer.reject!
        render json: { offer: offer, errors: {} }, status: :ok
      else
        render json: { errors: offer.errors }, status: :unprocessable_entity
      end
    end

    private

    def render_offers(resource, status: :ok)
      if resource.is_a?(Offer)
        render json: {
          offer: serialize_offer(resource),
          errors: {}
        }, status: status
      else
        render_grouped_offers(resource, status)
      end
    end

    def render_grouped_offers(offers, status)
      grouped = offers.group_by(&:request)
      requests = grouped.map do |request_obj, request_offers|
        serialize_request(request_obj, request_offers)
      end

      render json: { requests: requests, errors: {} }, status: status
    end

    def serialize_offer(offer)
      offer.as_json(
        except: %i[request_id printer_user_id created_at updated_at color_id filament_id],
        include: {
          printer_user: {
            only: %i[id],
            include: {
              user: { only: %i[id username] },
              printer: { only: %i[id model] }
            }
          },
          color: {},
          filament: {}
        }
      )
    end

    def serialize_request(request, offers)
      request.as_json(
        except: %i[user_id created_at updated_at],
        include: {
          user: {
            only: %i[id username],
            include: {
              country: { only: %i[id name] }
            }
          }
        }
      ).merge(
        offers: offers.map { |offer| serialize_offer(offer) }
      )
    end

    def filter_offers
      case params[:type]
      when 'all' # Offers received on my requests
        Offer.not_in_accepted_request.for_user_requests(current_user)
      when 'mine' # Offers sent to another user's requests
        Offer.not_in_accepted_request.from_user_printers(current_user)
      else
        Offer.none
      end
    end

    def offer_params
      params.require(:offer).permit(
        :request_id, :printer_user_id, :color_id, :filament_id,
        :price, :print_quality, :target_date
      )
    end

    def set_offer
      @offer = current_user.offers.find(params[:id])
    end
  end
end
