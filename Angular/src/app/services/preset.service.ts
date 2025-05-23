import { Injectable } from '@angular/core';
import { PresetModel } from '../models/preset.model';
import { ColorModel } from '../models/color.model';
import { FilamentModel } from '../models/filament.model';
import { PrinterModel } from '../models/printer.model';

import { ApiRequestService } from './api.service';
import { ApiResponseModel } from '../models/api-response.model';

import { map, Observable, of } from 'rxjs';
import { TranslationService } from './translation.service';

@Injectable({
  providedIn: 'root',
})
export class PresetService {
  requests: PresetModel[] = [];

  private cachedColors: ColorModel[] | null = null;
  private cachedFilaments: FilamentModel[] | null = null;
  private cachedPrinters: PrinterModel[] | null = null;

  constructor(
    private api: ApiRequestService,
    private translationService: TranslationService
  ) {}

  getAllPresets(): Observable<PresetModel[]> {
    return this.api.getRequest('api/preset').pipe(
      map((response: ApiResponseModel) => {
        if (response.status === 200) {
          return (response.data as any[]).map(
            (item) =>
              ({
                id: item.id,
                printQuality: item.print_quality,
                color: {
                  id: item.color.id,
                  name: this.translationService.translateColor(item.color.id),
                },
                filament: {
                  id: item.filament.id,
                  name: this.translationService.translateFilament(
                    item.filament.id
                  ),
                },
              } as PresetModel)
          );
        }
        return [];
      })
    );
  }

  getAllColors(): Observable<ColorModel[]> {
    if (this.cachedColors) {
      return of(this.cachedColors);
    }

    return this.api.getRequest('api/color').pipe(
      map((response: ApiResponseModel) => {
        if (response.status === 200) {
          this.cachedColors = (response.data as ColorModel[]).map((color) => ({
            id: color.id,
            name: this.translationService.translateColor(color.id),
          }));
          return this.cachedColors;
        }
        return [];
      })
    );
  }

  getAllFilaments(): Observable<FilamentModel[]> {
    if (this.cachedFilaments) {
      return of(this.cachedFilaments);
    }

    return this.api.getRequest('api/filament').pipe(
      map((response: ApiResponseModel) => {
        if (response.status === 200) {
          this.cachedFilaments = (response.data as FilamentModel[]).map(
            (filament) => ({
              ...filament,
              name: this.translationService.translateFilament(filament.id),
            })
          );
          return this.cachedFilaments;
        }
        return [];
      })
    );
  }

  getAllPrinters(): Observable<PrinterModel[]> {
    if (this.cachedPrinters) {
      return of(this.cachedPrinters);
    }

    return this.api.getRequest('api/printer').pipe(
      map((response: ApiResponseModel) => {
        if (response.status === 200) {
          this.cachedPrinters = response.data as PrinterModel[];
          return this.cachedPrinters;
        }
        return [];
      })
    );
  }
}
