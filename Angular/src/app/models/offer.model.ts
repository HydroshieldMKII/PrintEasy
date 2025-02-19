import { RequestModel } from "./request.model";
import { PrinterModel } from "./printer.model";
import { ColorModel } from "./color.model";
import { FilamentModel } from "./filament.model";

export class OfferModel {
    id: number;
    request: RequestModel;
    printer: PrinterModel;
    color: ColorModel;
    filament: FilamentModel;
    price: number;
    print_quality: number;
    target_date: Date;

    constructor(
        id: number,
        request: RequestModel,
        printer: PrinterModel,
        color: ColorModel,
        filament: FilamentModel,
        price: number,
        print_quality: number,
        target_date: Date
    ) {
        this.id = id;
        this.request = request;
        this.printer = printer;
        this.color = color;
        this.filament = filament;
        this.price = price;
        this.print_quality = print_quality;
        this.target_date = target_date
    }
}
