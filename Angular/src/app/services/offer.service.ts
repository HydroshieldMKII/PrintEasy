import { inject, Injectable } from '@angular/core';
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
export class OfferService {
    messageService: MessageService = inject(MessageService);
    offers: OfferModel[] = [];

    constructor(private api: ApiRequestService) { }

    getOffers(): Observable<OfferModel[]> {
        return this.api.getRequest('api/offer', { type: 'all' }).pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    return (response.data as any)?.['requests'].map((request: any) => {
                        return new OfferModel(
                            request?.['id'],
                            request?.['name'],
                            request?.['budget'],
                            new Date(request?.['target_date']).toISOString(),
                            request?.['offers']
                        );
                    });
                }
                return [];
            })
        );
    }

    getMyOffers(): Observable<OfferModel[]> {
        return this.api.getRequest('api/offer', { type: 'mine' }).pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    console.log("Offer: ", response.data);
                    return (response.data as any)?.['requests'].map((request: any) => {
                        return new OfferModel(
                            request?.['id'],
                            request?.['name'],
                            request?.['budget'],
                            new Date(request?.['target_date']).toISOString(),
                            request?.['offers']
                        );
                    });
                }
                return [];
            })
        );
    }

    getOfferById(id: number): Observable<OfferModel | null> {
        console.log("fetching info for offer ID: ", id);
        return this.api.getRequest(`api/offer/${id}`).pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    const request = response.data?.['request'];
                    console.log("Fetched offer: ", request);
                    return new OfferModel(
                        request?.['id'],
                        request?.['name'],
                        request?.['budget'],
                        new Date(request?.['target_date']).toISOString(),
                        request?.['offers']
                    );
                }
                return null;
            })
        );
    }

    createOffer(offer: FormData): Observable<ApiResponseModel> {
        console.log("Creating request: ", offer);
        return this.api.postRequest('api/request', {}, offer).pipe(
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

    deleteOffer(id: number): Observable<ApiResponseModel> {
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

    updateOffer(id: number, request: FormData): Observable<ApiResponseModel> {
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