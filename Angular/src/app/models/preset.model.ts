export class PresetModel {
    id: number;
    filamentType: string;
    color: string;
    diameter: number;
    printQuality: number

    constructor(id: number, filamentType: string, color: string, diameter: number, printQuality: number) {
        this.id = id;
        this.filamentType = filamentType;
        this.color = color;
        this.diameter = diameter;
        this.printQuality = printQuality;
    }
}
