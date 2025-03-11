import { Injectable, inject } from '@angular/core';
import { FilamentModel } from '../models/filament.model';
import { ColorModel } from '../models/color.model';
import { TranslateService } from '@ngx-translate/core';

@Injectable({
  providedIn: 'root',
})
export class TranslationService {
  translateService = inject(TranslateService);
  constructor() {}

  translateFilament(id: number): string {
    const key = FilamentModel.filamentMap[id];
    return key
      ? this.translateService.instant(`materials.${key}`)
      : `Unknown Filament (${id})`;
  }

  translateColor(id: number): string {
    const key = ColorModel.colorMap[id];
    return key
      ? this.translateService.instant(`colors.${key}`)
      : `Unknown Color (${id})`;
  }
}
