# frozen_string_literal: true

module Api
  class OfferController < AuthenticatedController
    before_action :set_offer, only: %i[show update destroy]

    def index
      @offers = filter_offers
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
      if @offer.can_destroy? && @offer.destroy
        render json: { offer: @offer, errors: {} }, status: :ok
      else
        render json: { errors: @offer.errors }, status: :unprocessable_entity
      end
    end

    def reject
      offer = Offer.find(params[:id])

      if offer.can_reject? && offer.reject!
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
        # Use a SQL-based approach for grouping
        requests_with_offers = render_grouped_offers(resource)
        render json: { requests: requests_with_offers, errors: {} }, status: status
      end
    end

    def render_grouped_offers(offers)
      # Get all unique request IDs from the offers
      request_ids = offers.pluck(:request_id).uniq

      # Fetch the requests with necessary includes
      requests = Request.includes(user: :country)
                        .where(id: request_ids)
                        .as_json(
                          except: %i[user_id created_at updated_at],
                          include: {
                            user: {
                              only: %i[id username],
                              include: {
                                country: { only: %i[id name] }
                              }
                            }
                          }
                        )

      # Attach the offers to each request
      requests.map do |request|
        # Get offers for this request
        request_offers = offers.select { |o| o.request_id == request['id'] }

        # Serialize each offer
        request.merge(
          'offers' => request_offers.map { |offer| serialize_offer(offer) }
        )
      end
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

    def filter_offers
      case params[:type]
      when 'all' # Offers received on my requests
        Offer.not_in_accepted_request.for_user_requests
      when 'mine' # Offers sent to another user's requests
        Offer.not_in_accepted_request.from_user_printers
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
      printer_user_ids = PrinterUser.where(user: current_user).select(:id)
      @offer = Offer.where(printer_user_id: printer_user_ids).find(params[:id])
    end
  end
end
