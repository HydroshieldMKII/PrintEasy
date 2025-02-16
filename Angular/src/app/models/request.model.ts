import { PresetModel } from './preset.model';

export class RequestModel {
    id: number;
    name: string; // "Cool print idea"
    budget: number; // 5
    targetDate: Date; // e.g., "2021-01-01"
    country: string; // "Canada"
    printerModel: string; // "Creality 3"
    preset: PresetModel;

    constructor(
        id: number,
        name: string,
        budget: number,
        targetDate: Date,
        country: string,
        printerModel: string,
        preset: PresetModel
    ) {
        this.id = id;
        this.name = name;
        this.budget = budget;
        this.targetDate = targetDate;
        this.country = country;
        this.printerModel = printerModel;
        this.preset = preset;
    }
}
