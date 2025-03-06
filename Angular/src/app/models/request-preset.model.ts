import { ColorModel, ColorApi } from "./color.model";
import { FilamentModel, FilamentApi } from "./filament.model";
import { PrinterModel, PrinterApi } from "./printer.model";

export type RequestPresetApi = {
    id: number;
    print_quality: number;
    color: ColorApi;
    filament: FilamentApi;
    printer: PrinterApi;
    has_matching_offer_by_current_user: boolean;
}

export class RequestPresetModel {
    id: number;
    printQuality: number;
    color: ColorModel;
    filamentType: FilamentModel;
    printerModel: PrinterModel;
    hasOfferMade: boolean;

    constructor(
        id: number,
        printQuality: number,
        color: ColorModel,
        filamentType: FilamentModel,
        printerModel: PrinterModel,
        hasOfferMade: boolean
    ) {
        this.id = id;
        this.printQuality = printQuality;
        this.color = color;
        this.filamentType = filamentType;
        this.printerModel = printerModel;
        this.hasOfferMade = hasOfferMade;
    }

    static fromAPI(data: RequestPresetApi): RequestPresetModel {
        return new RequestPresetModel(
            data.id,
            data.print_quality,
            new ColorModel(data.color.id, data.color.name),
            new FilamentModel(data.filament.id, data.filament.name),
            new PrinterModel(data.printer.id, data.printer.model),
            data.has_matching_offer_by_current_user
        );
    }
}
