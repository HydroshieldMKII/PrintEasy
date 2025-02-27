import { inject, Injectable } from '@angular/core';
import { RequestModel } from '../models/request.model';
import { RequestPresetModel } from '../models/request-preset.model';
import { UserModel } from '../models/user.model';
import { PrinterModel } from '../models/printer.model';
import { FilamentModel } from '../models/filament.model';
import { ColorModel } from '../models/color.model';

import { ApiRequestService } from './api.service';
import { ApiResponseModel } from '../models/api-response.model';

import { map } from 'rxjs/operators';
import { Observable } from 'rxjs';
import { MessageService } from 'primeng/api';
import { TranslateService } from '@ngx-translate/core';

@Injectable({
    providedIn: 'root'
})
export class RequestService {
    messageService: MessageService = inject(MessageService);
    requests: RequestModel[] = [];

    // Mapping IDs to translation keys
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

    constructor(
        private api: ApiRequestService,
        private translate: TranslateService
    ) { }

    filter(filterParams: string, sortCategory: string, orderParams: string, searchParams: string, type: string): Observable<[RequestModel[], boolean]> {
        const params: any = {};

        if (filterParams) params.filter = filterParams;
        if (sortCategory) params.sortCategory = sortCategory;
        if (orderParams) params.sort = orderParams;
        if (searchParams) params.search = searchParams;
        if (type) params.type = type;

        console.log("Filter params: ", params);
        return this.fetchRequests(params);
    }


    getPrintersUser(): Observable<any> {
        return this.api.getRequest('api/printer_user').pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    console.log("Printer user response: ", response.data);
                    return response.data;
                }
                return false;
            })
        );
    }

    getRequestById(id: number): Observable<RequestModel | null> {
        console.log("fetching info for request ID: ", id);
        return this.api.getRequest(`api/request/${id}`).pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    const request = response.data?.['request'];
                    const user = new UserModel(
                        request?.['user']?.['id'],
                        request?.['user']?.['username'],
                        request?.['user']?.['country']?.['name']
                    );

                    const presets = (request?.['preset_requests'] as any[]).map((preset: any) => {
                        return new RequestPresetModel(
                            preset?.['id'],
                            preset?.['print_quality'],
                            new ColorModel(
                                preset?.['color']?.['id'],
                                this.translateColor(preset?.['color']?.['id'])
                            ),
                            new FilamentModel(
                                preset?.['filament']?.['id'],
                                this.translateFilament(preset?.['filament']?.['id'])
                            ),
                            new PrinterModel(preset?.['printer']?.['id'], preset?.['printer']?.['model'])
                        );
                    });

                    return new RequestModel(
                        request?.['id'],
                        request?.['name'],
                        request?.['budget'],
                        new Date(request?.['target_date']),
                        request?.['comment'],
                        request?.['stl_file_url'],
                        presets,
                        user,
                        request?.['has_offer_made?'],
                        request?.['has_offer_accepted?']
                    );
                }
                return null;
            })
        );
    }

    fetchRequests(params: any): Observable<[RequestModel[], boolean]> {
        return this.api.getRequest('api/request', params).pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    console.log("Requests response: ", response.data);
                    this.requests = (response.data as any)?.['request'].map((request: any) => {
                        const user = new UserModel(
                            request?.['user']?.['id'],
                            request?.['user']?.['username'],
                            request?.['user']?.['country']?.['name']
                        );

                        const presets = (request?.['preset_requests'] as any[]).map((preset: any) => {
                            return new RequestPresetModel(
                                preset?.['id'],
                                preset?.['print_quality'],
                                new ColorModel(
                                    preset?.['color']?.['id'],
                                    this.translateColor(preset?.['color']?.['id'])
                                ),
                                new FilamentModel(
                                    preset?.['filament']?.['id'],
                                    this.translateFilament(preset?.['filament']?.['id'])
                                ),
                                preset?.['printer']?.['model']
                            );
                        });

                        return new RequestModel(
                            request?.['id'],
                            request?.['name'],
                            request?.['budget'],
                            new Date(request?.['target_date']),
                            request?.['comment'],
                            request?.['stl_file_url'],
                            presets,
                            user,
                            request?.['has_offer_made?'],
                            request?.['has_offer_accepted?']
                        );
                    });
                }
                return [this.requests, response.data?.['has_printer']];
            })
        );
    }

    createRequest(request: FormData): Observable<ApiResponseModel> {
        console.log("Creating request: ", request);
        return this.api.postRequest('api/request', {}, request).pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 201) {
                    this.messageService.add({ severity: 'success', summary: 'Success', detail: 'Request created successfully' });
                } else {
                    if (response.status === 422) {
                        for (const [key, value] of Object.entries(response.errors)) {
                            this.messageService.add({ severity: 'error', summary: 'Error', detail: `${key}: ${value}` });
                        }
                    }
                }
                return response;
            })
        );
    }

    deleteRequest(id: number): Observable<ApiResponseModel> {
        return this.api.deleteRequest(`api/request/${id}`).pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    this.messageService.add({ severity: 'success', summary: 'Success', detail: 'Request deleted successfully' });
                } else {
                    this.messageService.add({ severity: 'error', summary: 'Error', detail: 'Request deletion failed' });
                }
                return response;
            })
        );
    }

    updateRequest(id: number, request: FormData): Observable<ApiResponseModel> {
        return this.api.putRequest(`api/request/${id}`, {}, request).pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    this.messageService.add({ severity: 'success', summary: 'Success', detail: 'Request updated successfully' });
                } else {
                    if (response.status === 422) {
                        for (const [key, value] of Object.entries(response.errors)) {
                            this.messageService.add({ severity: 'error', summary: 'Error', detail: `${key}: ${value}` });
                        }
                    }
                }
                return response;
            })
        );
    }

    // Helper function to translate a filament by ID
    private translateFilament(id: number): string {
        const key = this.filamentMap[id];
        return key ? this.translate.instant(`materials.${key}`) : `Unknown Filament (${id})`;
    }

    // Helper function to translate a color by ID
    private translateColor(id: number): string {
        const key = this.colorMap[id];
        return key ? this.translate.instant(`colors.${key}`) : `Unknown Color (${id})`;
    }
}