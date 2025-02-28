# frozen_string_literal: true

module Api
  class ColorController < AuthenticatedController
    def index
      colors = Color.all
      render json: colors
    end
  end
end
