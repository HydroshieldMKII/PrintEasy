import { inject, Injectable } from '@angular/core';
import { RequestModel } from '../models/request.model';
import { PresetModel } from '../models/preset.model';
import { OfferModel } from '../models/offer.model';
import { UserModel } from '../models/user.model';
import { PrinterModel } from '../models/printer.model';
import { FilamentModel } from '../models/filament.model';
import { ColorModel } from '../models/color.model';

import { ApiRequestService } from './api.service';
import { ApiResponseModel } from '../models/api-response.model';

import { map } from 'rxjs/operators';
import { Observable } from 'rxjs';
import { MessageService } from 'primeng/api';
import { PrinterUserModel } from '../models/printer-user.model';

@Injectable({
    providedIn: 'root'
})
export class RequestService {
    messageService: MessageService = inject(MessageService);
    requests: RequestModel[] = [];

    constructor(private api: ApiRequestService) { }

    getOfferById(id: number): Observable<OfferModel | null> {
        console.log("fetching info for offer ID: ", id);
        return this.api.getRequest(`api/offer/${id}`).pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    const offer = response.data?.['offer'];

                    const filament = new FilamentModel(
                        offer?.['filament']?.['id'],
                        offer?.['filament']?.['name']
                    );

                    const color = new ColorModel(
                        offer?.['color']?.['id'],
                        offer?.['color']?.['name']
                    );

                    return new OfferModel(
                        offer?.['id'],
                        offer?.['request'],
                        new PrinterUserModel(
                            offer?.['printer_user']?.['id'],
                            new UserModel(
                                offer?.['printer_user']?.['user']?.['id'],
                                offer?.['printer_user']?.['user']?.['username'],
                                offer?.['printer_user']?.['user']?.['country']?.['name']
                            ),
                            new PrinterModel(
                                offer?.['printer_user']?.['printer']?.['id'],
                                offer?.['printer_user']?.['printer']?.['model']
                            ),
                            new Date(offer?.['printer_user']?.['acquired_date'])
                        ),
                        filament,
                        color,
                        offer?.['price'],
                        offer?.['print_quality'],
                        offer?.['target_date']
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
                            return new PresetModel(
                                preset?.['id'],
                                preset?.['print_quality'],
                                preset?.['color']?.['name'],
                                preset?.['filament']?.['name'],
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
}