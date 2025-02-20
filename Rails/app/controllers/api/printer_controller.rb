class Api::PrinterController < AuthenticatedController
    def index
        @printers = Printer.all
        render json: @printers
    end
end
