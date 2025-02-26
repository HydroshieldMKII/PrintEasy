import { RequestModel } from "./request.model";
import { PrinterUserModel } from "./printer-user.model";
import { ColorModel } from "./color.model";
import { FilamentModel } from "./filament.model";

export class OfferModel {
    id: number;
    request: RequestModel;
    printer_user: PrinterUserModel;
    color: ColorModel;
    filament: FilamentModel;
    price: number;
    print_quality: number;
    target_date: Date;
    cancelled_at?: Date | null;


    constructor(
        id: number,
        request: RequestModel,
        printer_user: PrinterUserModel,
        color: ColorModel,
        filament: FilamentModel,
        price: number,
        print_quality: number,
        target_date: Date,
        cancelled_at?: Date | null
    ) {
        this.id = id;
        this.request = request;
        this.printer_user = printer_user;
        this.color = color;
        this.filament = filament;
        this.price = price;
        this.print_quality = print_quality;
        this.target_date = target_date
        this.cancelled_at = cancelled_at;
    }
}
