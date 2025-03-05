# frozen_string_literal: true

module Api
  class OfferController < AuthenticatedController
    before_action :set_offer, only: %i[show update destroy]

    def index
      @offers = Offer.filter_by_type(params[:type])
                     .includes(:request, printer_user: %i[user printer], color: [], filament: [])
                     .order(:target_date)
      render_offers(@offers)
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
      if @offer.destroy
        render json: { offer: @offer, errors: {} }, status: :ok
      else
        render json: { errors: @offer.errors }, status: :unprocessable_entity
      end
    end

    def reject
      offer = Offer.joins(:request).where(requests: { user: current_user }).find(params[:id])

      if offer.reject!
        render json: { offer: offer, errors: {} }, status: :ok
      else
        render json: { errors: offer.errors }, status: :unprocessable_entity
      end
    end

    private

    def render_offers(resource, status: :ok)
      if resource.is_a?(Offer) # Single offer
        render json: {
          offer: resource.serialize,
          errors: {}
        }, status: status
      else # Many offers by request
        requests_with_offers = Offer.group_by_request(resource)
        render json: { requests: requests_with_offers, errors: {} }, status: status
      end
    end

    def offer_params
      params.require(:offer).permit(
        :request_id, :printer_user_id, :color_id, :filament_id,
        :price, :print_quality, :target_date
      )
    end

    def set_offer
      @offer = Offer.where(printer_user: current_user.printer_users).find(params[:id])
    end
  end
end
