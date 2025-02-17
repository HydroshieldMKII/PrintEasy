export class PresetModel {
    printQuality: number;
    color: string;
    filamentType: string;
    printerModel: string;

    constructor(printQuality: number, color: string, filamentType: string, printerModel: string) {
        this.printQuality = printQuality;
        this.color = color;
        this.filamentType = filamentType;
        this.printerModel = printerModel;
    }
}
