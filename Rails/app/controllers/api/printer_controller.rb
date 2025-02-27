# frozen_string_literal: true

module Api
  class PrinterController < AuthenticatedController
    def index
      @printers = Printer.all
      render json: @printers
    end
  end
end
