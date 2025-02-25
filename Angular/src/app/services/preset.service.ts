import { inject, Injectable } from '@angular/core';
import { PresetModel } from '../models/preset.model';
import { ColorModel } from '../models/color.model';
import { FilamentModel } from '../models/filament.model';
import { PrinterModel } from '../models/printer.model';

import { ApiRequestService } from './api.service';
import { ApiResponseModel } from '../models/api-response.model';

import { map, Observable, of } from 'rxjs';
import { MessageService } from 'primeng/api';

@Injectable({
    providedIn: 'root'
})
export class PresetService {
    messageService: MessageService = inject(MessageService);
    requests: PresetModel[] = [];

    private cachedColors: ColorModel[] | null = null;
    private cachedFilaments: FilamentModel[] | null = null;
    private cachedPrinters: PrinterModel[] | null = null;

    constructor(private api: ApiRequestService) { }

    getAllColors(): Observable<ColorModel[]> {
        if (this.cachedColors) {
            console.log("Returning cached colors");
            return of(this.cachedColors);
        }

        return this.api.getRequest('api/color').pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    console.log("Fetched Colors:", response.data);
                    this.cachedColors = response.data as ColorModel[];
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
                    this.cachedFilaments = response.data as FilamentModel[];
                    return this.cachedFilaments;
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
}
