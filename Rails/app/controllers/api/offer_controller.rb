class Api::OfferController < AuthenticatedController
    def index
        offers = Offer.all
        render json: offers
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
    def offer_params
        # params.require(:offer).permit(:name, :description, :price, :image_url)
    end
end