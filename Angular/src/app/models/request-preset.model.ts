import { ColorModel } from "./color.model";
import { FilamentModel } from "./filament.model";
import { PrinterModel } from "./printer.model";

export class RequestPresetModel {
    id: number;
    printQuality: number;
    color: ColorModel;
    filamentType: FilamentModel;
    printerModel: PrinterModel;

    constructor(
        id: number, 
        printQuality: number, 
        color: ColorModel, 
        filamentType: FilamentModel, 
        printerModel: PrinterModel
    ) {
        this.id = id;
        this.printQuality = printQuality;
        this.color = color;
        this.filamentType = filamentType;
        this.printerModel = printerModel;
    }

    static fromAPI(data: any): RequestPresetModel | null {
        if (!data) {
            return null;
        }
        return new RequestPresetModel(
            data.id,
            data.print_quality,
            new ColorModel(data.color.id, data.color.name),
            new FilamentModel(data.filament.id, data.filament.name),
            new PrinterModel(data.printer.id, data.printer.model)
        );
    }
}
