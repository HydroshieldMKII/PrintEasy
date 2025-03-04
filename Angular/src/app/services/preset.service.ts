import { inject, Injectable } from '@angular/core';
import { PresetModel } from '../models/preset.model';
import { ColorModel } from '../models/color.model';
import { FilamentModel } from '../models/filament.model';
import { PrinterModel } from '../models/printer.model';

import { ApiRequestService } from './api.service';
import { ApiResponseModel } from '../models/api-response.model';

import { map, Observable, of } from 'rxjs';
import { PrinterUserModel, PrinterUserApi } from '../models/printer-user.model';
import { TranslateService } from '@ngx-translate/core';

@Injectable({
    providedIn: 'root'
})
export class PresetService {
    requests: PresetModel[] = [];

    private cachedColors: ColorModel[] | null = null;
    private cachedFilaments: FilamentModel[] | null = null;
    private cachedPrinters: PrinterModel[] | null = null;

    // Mapping for translation keys
    private filamentMap: Record<number, string> = {
        1: 'petg',
        2: 'tpu',
        3: 'nylon',
        4: 'wood',
        5: 'metal',
        6: 'carbon_fiber'
    };

    private colorMap: Record<number, string> = {
        1: 'red',
        2: 'blue',
        3: 'green',
        4: 'yellow',
        5: 'black',
        6: 'white',
        7: 'orange',
        8: 'purple',
        9: 'pink',
        10: 'brown',
        11: 'gray'
    };

    constructor(private api: ApiRequestService, private translate: TranslateService) { }

    getAllPresets(): Observable<PresetModel[]> {
        return this.api.getRequest('api/preset').pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    console.log("Fetched Presets:", response.data);
                    return (response.data as any[]).map(item => ({
                        id: item.id,
                        printQuality: item.print_quality,
                        color: {
                            id: item.color.id,
                            name: this.translateColor(item.color.id)
                        },
                        filament: {
                            id: item.filament.id,
                            name: this.translateFilament(item.filament.id)
                        }
                    } as PresetModel));
                }
                return [];
            })
        );
    }

    getAllColors(): Observable<ColorModel[]> {
        if (this.cachedColors) {
            console.log("Returning cached colors");
            return of(this.cachedColors);
        }

        return this.api.getRequest('api/color').pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    console.log("Fetched Colors:", response.data);
                    this.cachedColors = (response.data as ColorModel[]).map(color => new ColorModel(color.id, color.name));
                    return this.cachedColors;
                }
                return [];
            })
        );
    }

    getAllFilaments(): Observable<FilamentModel[]> {
        if (this.cachedFilaments) {
            console.log("Returning cached filaments");
            return of(this.cachedFilaments);
        }

        return this.api.getRequest('api/filament').pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    console.log("Fetched Filaments:", response.data);
                    this.cachedFilaments = (response.data as FilamentModel[]).map(filament => ({
                        ...filament,
                        name: this.translateFilament(filament.id)
                    }));
                    return this.cachedFilaments;
                }
                return [];
            })
        );
    }

    getPrinterUsers(): Observable<PrinterUserModel[]> {
        return this.api.getRequest('api/printer_user').pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    console.log("Fetched Printer Users:", response.data);
                    return (response.data as PrinterUserApi[]).map(printerUser => PrinterUserModel.fromAPI(printerUser));
                }
                return [];
            })
        );
    }

    getAllPrinters(): Observable<PrinterModel[]> {
        if (this.cachedPrinters) {
            console.log("Returning cached printers");
            return of(this.cachedPrinters);
        }

        return this.api.getRequest('api/printer').pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    console.log("Fetched Printers:", response.data);
                    this.cachedPrinters = response.data as PrinterModel[];
                    return this.cachedPrinters;
                }
                return [];
            })
        );
    }

    private translateFilament(id: number): string {
        const key = this.filamentMap[id];
        return key ? this.translate.instant(`materials.${key}`) : `Unknown Filament (${id})`;
    }

    private translateColor(id: number): string {
        const key = this.colorMap[id];
        return key ? this.translate.instant(`colors.${key}`) : `Unknown Color (${id})`;
    }
}