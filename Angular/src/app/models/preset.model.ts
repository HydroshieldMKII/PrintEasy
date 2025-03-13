import { ColorModel } from './color.model';
import { FilamentModel } from './filament.model';
import { UserModel } from './user.model';

export type PresetApi = {
  id: number;
  print_quality: number;
  color: ColorModel;
  filament_type: FilamentModel;
  printer_model: UserModel;
};

export class PresetModel {
  id: number;
  printQuality: number;
  color: ColorModel;
  filament: FilamentModel;
  user: UserModel;

  constructor(
    id: number,
    printQuality: number,
    color: ColorModel,
    filament: FilamentModel,
    user: UserModel
  ) {
    this.id = id;
    this.printQuality = printQuality;
    this.color = color;
    this.filament = filament;
    this.user = user;
  }

  static fromAPI(data: PresetApi): PresetModel | null {
    return new PresetModel(
      data.id,
      data.print_quality,
      data.color,
      data.filament_type,
      data.printer_model
    );
  }
}
