# frozen_string_literal: true

module Api
  class FilamentController < AuthenticatedController
    def index
      filaments = Filament.all
      render json: filaments
    end
  end
end
