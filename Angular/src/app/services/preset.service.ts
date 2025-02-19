import { inject, Injectable } from '@angular/core';
import { PresetModel } from '../models/preset.model';
import { ColorModel } from '../models/color.model';
import { FilamentModel } from '../models/filament.model';
import { PrinterModel } from '../models/printer.model';

import { ApiRequestService } from './api.service';
import { ApiResponseModel } from '../models/api-response.model';

import { map } from 'rxjs/operators';
import { Observable } from 'rxjs';
import { MessageService } from 'primeng/api';

@Injectable({
    providedIn: 'root'
})
export class PresetService {
    messageService: MessageService = inject(MessageService);
    requests: PresetModel[] = [];

    constructor(private api: ApiRequestService) { }

    getAllColors(): Observable<ColorModel[]> {
        return this.api.getRequest('api/color').pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    console.log("Colors response: ", response.data);
                    return response.data as ColorModel[];
                }
                return [];
            })
        );
    }

    getAllFilaments(): Observable<FilamentModel[]> {
        return this.api.getRequest('api/filament').pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    console.log("Filaments response: ", response.data);
                    return response.data as FilamentModel[];
                }
                return [];
            })
        );
    }

    getAllPrinters(): Observable<any> {
        return this.api.getRequest('api/printer').pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    console.log("Printers response: ", response.data);
                    return response.data as PrinterModel[];
                }
                return false;
            })
        );
    }
}