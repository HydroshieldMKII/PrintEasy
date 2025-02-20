class Api::FilamentController < ApplicationController
    before_action :authenticate_user!

    def index
        filaments = Filament.all
        render json: filaments
    end
end
