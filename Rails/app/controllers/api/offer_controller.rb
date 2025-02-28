# frozen_string_literal: true

module Api
  class OfferController < AuthenticatedController
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    before_action :set_offer, only: %i[show update destroy]
    before_action :check_printer_ownership, only: %i[create]
    before_action :validate_user_owns_printer_user, only: %i[create]
    before_action :validate_not_own_request, only: %i[create]

    def index
      render_offers(filter_offers(Offer.all))
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
      # debugger
      @offer.errors.add(:offer, 'Offer already accepted. Cannot delete') if Order.exists?(offer_id: @offer.id)

      @offer.errors.add(:offer, 'Offer already rejected. Cannot delete') if @offer.cancelled_at

      if @offer.errors.empty? && @offer.destroy
        render json: { offer: @offer, errors: {} }, status: :ok
      else
        render json: { errors: @offer.errors }, status: :unprocessable_entity
      end
    end

    def reject
      offers_on_my_requests = Offer.where(request_id: current_user.requests.pluck(:id))
      offer = offers_on_my_requests.find(params[:id])

      valid = true

      if Order.find_by(offer_id: offer.id)
        offer.errors.add(:offer, 'Offer already accepted. Cannot reject')
        valid = false
      end

      if offer.request.user != current_user
        offer.errors.add(:offer, 'You are not allowed to reject this offer')
        valid = false
      end

      if offer.cancelled_at
        offer.errors.add(:offer, 'Offer already rejected')
        valid = false
      end

      if valid && offer.reject!
        render json: { offer: offer, errors: {} }, status: :ok
      else
        render json: { errors: offer.errors }, status: :unprocessable_entity
      end
    end

    private

    def check_printer_ownership
      return if current_user.printer_user.exists?

      offer = Offer.new
      offer.errors.add(:offer, 'You need to have a printer to create an offer')
      render json: { errors: offer.errors }, status: :unprocessable_entity
    end

    def validate_user_owns_printer_user
      return if params[:offer].blank? || params[:offer][:printer_user_id].blank?
      return if current_user.printer_user.pluck(:id).include?(params[:offer][:printer_user_id].to_i)

      offer = Offer.new
      offer.errors.add(:offer, 'You are not allowed to create an offer on this printer')
      render json: { errors: offer.errors }, status: :unprocessable_entity
    end

    def validate_not_own_request
      return if params[:offer].blank? || params[:offer][:request_id].blank?

      request = Request.find_by(id: params[:offer][:request_id])
      return if request.nil? || request.user_id != current_user.id

      offer = Offer.new
      offer.errors.add(:offer, 'You cannot create an offer on your own request')
      render json: { errors: offer.errors }, status: :unprocessable_entity
    end

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
      # Filtrer les offres NE faisant PAS partie d'une request acceptée
      accepted_requests = Order.joins(:offer).pluck(:request_id).uniq
      offers = offers.where.not(id: Order.pluck(:offer_id)).where.not(request_id: accepted_requests)

      case params[:type]
      when 'all' # Offers received on my requests
        offers.where(request_id: current_user.requests.pluck(:id)).where.not(id: Order.pluck(:offer_id)).distinct
      when 'mine' # Offers sent to another user's requests
        offers.where(printer_user_id: current_user.printer_user.pluck(:id)).where.not(id: Order.pluck(:offer_id)).distinct
      else
        []
      end
    end

    def offer_params
      params.require(:offer).permit(:request_id, :printer_user_id, :color_id, :filament_id, :price, :print_quality,
                                    :target_date)
    end

    def record_not_found
      render json: { errors: { offer: 'Offer not found' } }, status: :not_found
    end

    def set_offer
      @offer = current_user.offers.find(params[:id])
    end
  end
end
