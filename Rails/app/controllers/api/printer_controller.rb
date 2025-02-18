class Api::PrinterController < ApplicationController

    def index
        @printers = Printer.all
        render json: @printers
    end
end
