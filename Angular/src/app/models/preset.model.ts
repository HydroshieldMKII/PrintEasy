export class PresetModel {
    id: number;
    filamentType: string;
    color: string;
    printQuality: number;

    constructor(id: number, filamentType: string, color: string, printQuality: number) {
        this.id = id;
        this.filamentType = filamentType;
        this.color = color;
        this.printQuality = printQuality;
    }
}
