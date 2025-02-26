import { ColorModel } from "./color.model";
import { FilamentModel } from "./filament.model";
import { UserModel } from "./user.model";

export class PresetModel {
    id: number;
    printQuality: number;
    color: ColorModel;
    filament: FilamentModel;
    user: UserModel;

    constructor(id: number, printQuality: number, color: ColorModel, filament: FilamentModel, user: UserModel) {
        this.id = id;
        this.printQuality = printQuality;
        this.color = color;
        this.filament = filament;
        this.user = user;
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