# frozen_string_literal: true

module Api
  class StatusController < ApplicationController
    def index
      @statuses = Status.all
      render json: { statuses: @statuses.as_json(except: %i[created_at updated_at]) }, status: :ok
    end
  end
end
