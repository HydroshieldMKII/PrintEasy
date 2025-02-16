export class PresetModel {
    id: number;
    filamentType: string;
    color: string;
    diameter: number;

    constructor(id: number, filamentType: string, color: string, diameter: number) {
        this.id = id;
        this.filamentType = filamentType;
        this.color = color;
        this.diameter = diameter
    }
}
