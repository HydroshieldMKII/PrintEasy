class Api::PrinterController < ApplicationController
    before_action :authenticate_user!

    def index
        @printers = Printer.all
        render json: @printers
    end
end
