class Api::ColorController < ApplicationController
    before_action :authenticate_user!

    def index
        colors = Color.all
        render json: colors
    end
end
