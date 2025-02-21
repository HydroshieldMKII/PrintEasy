export class PresetModel {
    id: number;
    printQuality: number;
    color: string;
    filamentType: string;
    printerModel: string;

    constructor(id: number, printQuality: number, color: string, filamentType: string, printerModel: string) {
        this.id = id;
        this.printQuality = printQuality;
        this.color = color;
        this.filamentType = filamentType;
        this.printerModel = printerModel;
    }

    static fromAPI(data: any): PresetModel {
        return new PresetModel(
            data.id,
            data.print_quality,
            data.color,
            data.filament_type,
            data.printer_model
        );
    }
}
