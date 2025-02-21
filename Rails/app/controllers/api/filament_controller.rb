class Api::FilamentController < AuthenticatedController
    def index
        filaments = Filament.all
        render json: filaments
    end
end
