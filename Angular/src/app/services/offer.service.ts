import { inject, Injectable } from '@angular/core';
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
import { TranslateService } from '@ngx-translate/core';

@Injectable({
    providedIn: 'root'
})
export class OfferService {
    messageService: MessageService = inject(MessageService);
    offers: OfferModel[] = [];

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

    getOffers(): Observable<OfferModel[]> {
        return this.api.getRequest('api/offer', { type: 'all' }).pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    console.log("Offers: ", response.data);
                    return (response.data as any)?.['requests'].map((request: any) => {
                        return RequestOfferModel.fromAPI(request);
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
                        return RequestOfferModel.fromAPI(request);
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
                        this.translateColor(offer?.['color']?.['id'])
                    );

                    const filament = new FilamentModel(
                        offer?.['filament']?.['id'],
                        this.translateFilament(offer?.['filament']?.['id'])
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
                    this.messageService.add({
                        severity: 'success',
                        summary: this.translate.instant('global.success'),
                        detail: this.translate.instant('offer.created')
                    });
                } else if (response.status === 422 && response.errors['request'] == 'This offer already exists') {
                    this.messageService.add({
                        severity: 'error',
                        summary: this.translate.instant('global.error'),
                        detail: this.translate.instant('offer.error_already_exists')
                    });
                } else {
                    console.log("Error: ", response);
                    this.messageService.add({
                        severity: 'error',
                        summary: this.translate.instant('global.error'),
                        detail: this.translate.instant('offer.error_create')
                    });

                }
                return response;
            })
        );
    }

    deleteOffer(id: number): Observable<ApiResponseModel> {
        return this.api.deleteRequest(`api/offer/${id}`).pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    this.messageService.add({
                        severity: 'success',
                        summary: this.translate.instant('global.success'),
                        detail: this.translate.instant('offer.deleted')
                    });
                } else {
                    this.messageService.add({
                        severity: 'error',
                        summary: this.translate.instant('global.error'),
                        detail: this.translate.instant('offer.error_delete')
                    });
                }
                return response;
            })
        );
    }

    updateOffer(id: number, offer: FormData): Observable<ApiResponseModel> {
        return this.api.putRequest(`api/offer/${id}`, {}, offer).pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    this.messageService.add({
                        severity: 'success',
                        summary: this.translate.instant('global.success'),
                        detail: this.translate.instant('offer.updated')
                    });
                } else {
                    console.log("Error: ", response);
                    if (response.status === 422 && response.errors['request'] == 'This offer already exists') {
                        this.messageService.add({
                            severity: 'error',
                            summary: this.translate.instant('global.error'),
                            detail: this.translate.instant('offer.error_already_exists')
                        });
                    } else {
                        this.messageService.add({
                            severity: 'error',
                            summary: this.translate.instant('global.error'),
                            detail: this.translate.instant('offer.error_update')
                        });
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
                    this.messageService.add({
                        severity: 'success',
                        summary: this.translate.instant('global.success'),
                        detail: this.translate.instant('offer.refuse_success')
                    });
                } else {
                    console.log("Error: ", response);
                    this.messageService.add({
                        severity: 'error',
                        summary: this.translate.instant('global.error'),
                        detail: this.translate.instant('offer.refuse_error')
                    });
                }
                return response;
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