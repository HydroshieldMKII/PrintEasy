import { inject, Injectable } from '@angular/core';
import { RequestModel } from '../models/request.model';
import { PresetModel } from '../models/preset.model';
import { RequestOfferModel } from '../models/request-offer.model';
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
                        return new RequestOfferModel(
                            request?.['id'],
                            request?.['name'],
                            request?.['budget'],
                            request?.['comment'],
                            new Date(request?.['target_date']),
                            (request?.['offers'] as any[]).map((offer: any) => {
                                // console.log("raw getOffer to create from: ", offer);
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
                                    new FilamentModel(
                                        offer?.['filament']?.['id'],
                                        offer?.['filament']?.['name']
                                    ),
                                    new ColorModel(
                                        offer?.['color']?.['id'],
                                        offer?.['color']?.['name']
                                    ),
                                    offer?.['price'],
                                    offer?.['print_quality'],
                                    offer?.['target_date'],
                                    offer?.['cancelled_at']
                                );
                            }
                            )
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
                        return new RequestOfferModel(
                            request?.['id'],
                            request?.['name'],
                            request?.['budget'],
                            request?.['comment'],
                            new Date(request?.['target_date']),
                            (request?.['offers'] as any[]).map((offer: any) => {
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
                                    new FilamentModel(
                                        offer?.['filament']?.['id'],
                                        offer?.['filament']?.['name']
                                    ),
                                    new ColorModel(
                                        offer?.['color']?.['id'],
                                        offer?.['color']?.['name']
                                    ),
                                    offer?.['price'],
                                    offer?.['print_quality'],
                                    offer?.['target_date'],
                                    offer?.['cancelled_at']
                                );
                            }
                            )
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
                    // console.log("raw getOfferById to create from: ", response.data);
                    const offer = response.data?.['offer'];

                    const color = new ColorModel(
                        offer?.['color']?.['id'],
                        offer?.['color']?.['name']
                    );

                    const filament = new FilamentModel(
                        offer?.['filament']?.['id'],
                        offer?.['filament']?.['name']
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
                        color,
                        filament,
                        offer?.['price'],
                        offer?.['print_quality'],
                        offer?.['target_date']
                    );
                }
                return null;
            })
        );
    }

    createOffer(offer: FormData): Observable<ApiResponseModel> {
        console.log("Creating request: ", offer);
        return this.api.postRequest('api/offer', {}, offer).pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 201) {
                    this.messageService.add({ severity: 'success', summary: 'Success', detail: 'Offer created successfully' });
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
        return this.api.deleteRequest(`api/offer/${id}`).pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    this.messageService.add({ severity: 'success', summary: 'Success', detail: 'Offer deleted successfully' });
                } else {
                    this.messageService.add({ severity: 'error', summary: 'Error', detail: 'Offer deletion failed' });
                }
                return response;
            })
        );
    }

    updateOffer(id: number, offer: FormData): Observable<ApiResponseModel> {
        return this.api.putRequest(`api/offer/${id}`, {}, offer).pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    this.messageService.add({ severity: 'success', summary: 'Success', detail: 'Offer updated successfully' });
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

    refuseOffer(id: number): Observable<ApiResponseModel> {
        return this.api.putRequest(`api/offer/${id}/reject`, {}).pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    this.messageService.add({ severity: 'success', summary: 'Success', detail: 'Offer canceled successfully' });
                } else {
                    console.log("Error: ", response);
                    this.messageService.add({ severity: 'error', summary: 'Error', detail: 'Offer cancelation failed' });
                }
                return response;
            })
        );
    }
}