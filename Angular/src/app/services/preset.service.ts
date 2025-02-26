import { inject, Injectable } from '@angular/core';
import { PresetModel } from '../models/preset.model';
import { ColorModel } from '../models/color.model';
import { FilamentModel } from '../models/filament.model';
import { PrinterModel } from '../models/printer.model';

import { ApiRequestService } from './api.service';
import { ApiResponseModel } from '../models/api-response.model';

import { map, Observable, of } from 'rxjs';
import { MessageService } from 'primeng/api';
import { PrinterUserModel } from '../models/printer-user.model';

@Injectable({
    providedIn: 'root'
})
export class PresetService {
    messageService: MessageService = inject(MessageService);
    requests: PresetModel[] = [];

    private cachedColors: ColorModel[] | null = null;
    private cachedFilaments: FilamentModel[] | null = null;
    private cachedPrinters: PrinterModel[] | null = null;
    private cachedPrinterUsers: PrinterUserModel[] | null = null;
    private cachedPresets: PresetModel[] | null = null;

    constructor(private api: ApiRequestService) { }

    getAllPresets(): Observable<PresetModel[]> {
        if (this.cachedPresets) {
            console.log("Returning cached presets");
            return of(this.cachedPresets);
        }

        return this.api.getRequest('api/preset').pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    this.cachedPresets = (response.data as any[]).map(item => ({
                        id: item.id,
                        printQuality: item.print_quality,
                        color: {
                            id: item.color.id,
                            name: item.color.name
                        },
                        filament: {
                            id: item.filament.id,
                            name: item.filament.name
                        }
                    } as PresetModel));
                    return this.cachedPresets;
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

    getPrinterUsers(): Observable<PrinterUserModel[]> {
        if (this.cachedPrinterUsers) {
            console.log("Returning cached printer users");
            return of(this.cachedPrinterUsers);
        }

        return this.api.getRequest('api/printer_user').pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    console.log("Fetched Printer Users:", response.data);
                    this.cachedPrinterUsers = (response.data as any[]).map(item => new PrinterUserModel(
                        item.id,
                        item.user,
                        item.printer,
                        new Date(item.acquired_date)
                    ));
                    return this.cachedPrinterUsers;
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
