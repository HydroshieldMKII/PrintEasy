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
}
