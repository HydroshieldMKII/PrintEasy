import { RequestModel } from "./request.model";
import { PrinterUserModel } from "./printer-user.model";
import { ColorModel } from "./color.model";
import { FilamentModel } from "./filament.model";

export class OfferModel {
    id: number;
    request: RequestModel;
    printerUser: PrinterUserModel;
    color: ColorModel;
    filament: FilamentModel;
    price: number;
    printQuality: number;
    targetDate: Date;

    constructor(
        id: number,
        request: RequestModel,
        printer_user: PrinterUserModel,
        color: ColorModel,
        filament: FilamentModel,
        price: number,
        print_quality: number,
        target_date: Date
    ) {
        this.id = id;
        this.request = request;
        this.printerUser = printer_user;
        this.color = color;
        this.filament = filament;
        this.price = price;
        this.printQuality = print_quality;
        this.targetDate = target_date
    }

    static fromAPI(data: any): OfferModel {
        return new OfferModel(
            data.id,
            RequestModel.fromAPI(data.request),
            PrinterUserModel.fromAPI(data.printer_user),
            ColorModel.fromAPI(data.color),
            FilamentModel.fromAPI(data.filament),
            data.price,
            data.print_quality,
            new Date(data.target_date)
        );
    }
}
