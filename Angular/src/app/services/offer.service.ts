import { inject, Injectable } from '@angular/core';
import {
  RequestOfferModel,
  RequestOfferApi,
} from '../models/request-offer.model';
import { OfferModel, OfferApi } from '../models/offer.model';
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
import { TranslationService } from './translation.service';

@Injectable({
  providedIn: 'root',
})
export class OfferService {
  messageService: MessageService = inject(MessageService);
  offers: OfferModel[] = [];

  constructor(
    private api: ApiRequestService,
    private translate: TranslateService,
    private translationService: TranslationService
  ) {}

  getOffers(): Observable<RequestOfferModel[] | ApiResponseModel> {
    return this.api.getRequest('api/offer', { type: 'all' }).pipe(
      map((response: ApiResponseModel) => {
        if (response.status === 200) {
          return (response.data.requests as any)?.map(
            (request: RequestOfferApi) => {
              request.offers = request.offers.map((offer: OfferApi) => {
                offer.color.name = this.translationService.translateColor(
                  offer.color.id
                );
                offer.filament.name = this.translationService.translateFilament(
                  offer.filament.id
                );
                return offer;
              });
              return RequestOfferModel.fromAPI(request);
            }
          );
        }
        return response;
      })
    );
  }

  getMyOffers(): Observable<RequestOfferModel[] | ApiResponseModel> {
    return this.api.getRequest('api/offer', { type: 'mine' }).pipe(
      map((response: ApiResponseModel) => {
        if (response.status === 200) {
          return (response.data.requests as RequestOfferApi[])?.map(
            (request: RequestOfferApi) => {
              request.offers.map((offer: OfferApi) => {
                offer.color.name = this.translationService.translateColor(
                  offer.color.id
                );
                offer.filament.name = this.translationService.translateFilament(
                  offer.filament.id
                );
              });
              return RequestOfferModel.fromAPI(request);
            }
          );
        }
        return response;
      })
    );
  }

  getOfferById(id: number): Observable<OfferModel | ApiResponseModel> {
    return this.api.getRequest(`api/offer/${id}`).pipe(
      map((response: ApiResponseModel) => {
        if (response.status === 200) {
          response.data.offer.color.name =
            this.translationService.translateColor(
              response.data.offer.color.id
            );
          response.data.offer.filament.name =
            this.translationService.translateFilament(
              response.data.offer.filament.id
            );
          return OfferModel.fromAPI(response.data.offer as OfferApi);
        }
        return response;
      })
    );
  }

  createOffer(offer: FormData): Observable<ApiResponseModel> {
    return this.api.postRequest('api/offer', {}, offer).pipe(
      map((response: ApiResponseModel) => {
        if (response.status === 201) {
          this.messageService.add({
            severity: 'success',
            summary: this.translate.instant('global.success'),
            detail: this.translate.instant('offer.created'),
          });
        } else if (
          response.status === 422 &&
          response.errors['request'] == 'This offer already exists'
        ) {
          this.messageService.add({
            severity: 'error',
            summary: this.translate.instant('global.error'),
            detail: this.translate.instant('offer.error_already_exists'),
          });
        } else if (
          response.errors['offer'] ==
          'Request already accepted an offer. Cannot create'
        ) {
          this.messageService.add({
            severity: 'error',
            summary: this.translate.instant('requestForm.error'),
            detail: this.translate.instant(
              'requestForm.request_accepted_error'
            ),
          });
        } else {
          this.messageService.add({
            severity: 'error',
            summary: this.translate.instant('global.error'),
            detail: this.translate.instant('offer.error_create'),
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
            detail: this.translate.instant('offer.deleted'),
          });
        } else {
          this.messageService.add({
            severity: 'error',
            summary: this.translate.instant('global.error'),
            detail: this.translate.instant('offer.error_delete'),
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
            detail: this.translate.instant('offer.updated'),
          });
        } else {
          if (
            response.status === 422 &&
            response.errors['request'] == 'This offer already exists'
          ) {
            this.messageService.add({
              severity: 'error',
              summary: this.translate.instant('global.error'),
              detail: this.translate.instant('offer.error_already_exists'),
            });
          } else {
            this.messageService.add({
              severity: 'error',
              summary: this.translate.instant('global.error'),
              detail: this.translate.instant('offer.error_update'),
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
            detail: this.translate.instant('offer.refuse_success'),
          });
        } else {
          this.messageService.add({
            severity: 'error',
            summary: this.translate.instant('global.error'),
            detail: this.translate.instant('offer.refuse_error'),
          });
        }
        return response;
      })
    );
  }
}
