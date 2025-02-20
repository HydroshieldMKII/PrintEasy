class Api::ColorController < AuthenticatedController
    def index
        colors = Color.all
        render json: colors
    end
end
