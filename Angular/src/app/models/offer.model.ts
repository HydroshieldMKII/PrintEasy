import { RequestModel, RequestApi } from "./request.model";
import { PrinterUserModel, PrinterUserApi } from "./printer-user.model";
import { ColorModel, ColorApi } from "./color.model";
import { FilamentModel, FilamentApi } from "./filament.model";

export type OfferApi = {
    id: number;
    request: RequestApi | null;
    printer_user: PrinterUserApi;
    color: ColorApi;
    filament: FilamentApi;
    price: number;
    print_quality: number;
    target_date: string;
    cancelled_at?: Date | null;
    accepted_at?: Date | null;
}

export class OfferModel {
    id: number;
    printerUser: PrinterUserModel;
    color: ColorModel;
    filament: FilamentModel;
    price: number;
    printQuality: number;
    targetDate: Date;
    cancelledAt?: Date | null;
    acceptedAt?: Date | null;
    request: RequestModel | null;

    constructor(
        id: number,
        printerUser: PrinterUserModel,
        color: ColorModel,
        filament: FilamentModel,
        price: number,
        printQuality: number,
        targetDate: Date,
        request: RequestModel | null,
        cancelledAt?: Date | null,
        acceptedAt?: Date | null,
    ) {
        this.id = id;
        this.printerUser = printerUser;
        this.color = color;
        this.filament = filament;
        this.price = price;
        this.printQuality = printQuality;
        this.targetDate = targetDate
        this.cancelledAt = cancelledAt;
        this.acceptedAt = acceptedAt;
        this.request = request;
    }

    static fromAPI(data: OfferApi): OfferModel {
        return new OfferModel(
            data.id,
            PrinterUserModel.fromAPI(data.printer_user),
            ColorModel.fromAPI(data.color),
            FilamentModel.fromAPI(data.filament),
            data.price,
            data.print_quality,
            new Date(data.target_date),
            data.request ? RequestModel.fromAPI(data.request) : null,
            data.cancelled_at ? new Date(data.cancelled_at) : null,
            data.accepted_at ? new Date(data.accepted_at) : null
        );
    }
}
