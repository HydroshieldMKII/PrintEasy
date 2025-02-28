import { RequestModel } from "./request.model";
import { PrinterUserModel } from "./printer-user.model";
import { ColorModel } from "./color.model";
import { FilamentModel } from "./filament.model";

export class OfferModel {
    id: number;
    request: RequestModel | null;
    printerUser: PrinterUserModel | null;
    color: ColorModel | null;
    filament: FilamentModel | null;
    price: number;
    printQuality: number;
    targetDate: Date;
    cancelledAt?: Date | null;


    constructor(
        id: number,
        request: RequestModel | null,
        printer_user: PrinterUserModel | null,
        color: ColorModel | null,
        filament: FilamentModel | null,
        price: number,
        print_quality: number,
        target_date: Date,
        cancelled_at?: Date | null
    ) {
        this.id = id;
        this.request = request;
        this.printerUser = printer_user;
        this.color = color;
        this.filament = filament;
        this.price = price;
        this.printQuality = print_quality;
        this.targetDate = target_date
        this.cancelledAt = cancelled_at;
    }

    static fromAPI(data: any): OfferModel | null {
        if (!data) {
            return null;
        }
        return new OfferModel(
            data.id,
            RequestModel.fromAPI(data.request),
            PrinterUserModel.fromAPI(data.printer_user),
            ColorModel.fromAPI(data.color),
            FilamentModel.fromAPI(data.filament),
            data.price,
            data.print_quality,
            new Date(data.target_date),
            new Date(data.cancelled_at)
        );
    }
}
