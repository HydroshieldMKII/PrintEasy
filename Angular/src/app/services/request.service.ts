import { inject, Injectable } from '@angular/core';
import { RequestModel, RequestApi } from '../models/request.model';
import { RequestPresetApi } from '../models/request-preset.model';

import { ApiRequestService } from './api.service';
import { ApiResponseModel } from '../models/api-response.model';

import { map } from 'rxjs/operators';
import { Observable } from 'rxjs';
import { MessageService } from 'primeng/api';
import { TranslationService } from './translation.service';
import { TranslateService } from '@ngx-translate/core';
import {
  RequestStatsApi,
  RequestStatsModel,
} from '../models/request-stats.model';

@Injectable({
  providedIn: 'root',
})
export class RequestService {
  messageService: MessageService = inject(MessageService);
  requests: RequestModel[] = [];

  constructor(
    private api: ApiRequestService,
    private translate: TranslateService,
    private translationService: TranslationService
  ) {}

  filter(
    sortCategory: string,
    orderParams: string,
    searchParams: string,
    minBudget: number | null,
    maxBudget: number | null,
    startDate: Date,
    endDate: Date,
    type: string,
    filters: string[] = []
  ): Observable<[RequestModel[], boolean] | ApiResponseModel> {
    const params: any = {};

    if (sortCategory) params.sortCategory = sortCategory;
    if (orderParams) params.sort = orderParams;
    if (searchParams) params.search = searchParams;
    if (minBudget !== undefined && minBudget !== null && minBudget !== 0)
      params.minBudget = minBudget;
    if (maxBudget !== undefined && maxBudget !== null && maxBudget !== 10000)
      params.maxBudget = maxBudget;
    if (startDate) params.startDate = startDate.toISOString().split('T')[0];
    if (endDate) params.endDate = endDate.toISOString().split('T')[0];
    if (type) params.type = type;

    if (filters && filters.length > 0) {
      params.filter = filters.join(',');
    }

    return this.fetchRequests(params);
  }

  getRequestById(id: number): Observable<RequestModel | ApiResponseModel> {
    return this.api.getRequest(`api/request/${id}`).pipe(
      map((response: ApiResponseModel) => {
        if (response.status === 200) {
          response.data.request.preset_requests.map(
            (preset: RequestPresetApi) => {
              preset.color.name = this.translationService.translateColor(
                preset.color.id
              );
              preset.filament.name = this.translationService.translateFilament(
                preset.filament.id
              );
            }
          );

          return RequestModel.fromAPI(response.data.request);
        } else {
          return response;
        }
      })
    );
  }

  fetchRequests(
    params: any
  ): Observable<[RequestModel[], boolean] | ApiResponseModel> {
    return this.api.getRequest('api/request', params).pipe(
      map((response: ApiResponseModel) => {
        if (response.status === 200) {
          this.requests = (response.data.request as RequestApi[])?.map(
            (requestData: RequestApi) => {
              requestData.preset_requests.map((preset) => {
                preset.color.name = this.translationService.translateColor(
                  preset.color.id
                );
                preset.filament.name =
                  this.translationService.translateFilament(preset.filament.id);
              });

              return RequestModel.fromAPI(requestData);
            }
          );
        }
        return [this.requests, response.data?.['has_printer']];
      })
    );
  }

  createRequest(request: FormData): Observable<ApiResponseModel> {
    return this.api.postRequest('api/request', {}, request).pipe(
      map((response: ApiResponseModel) => {
        if (response.status === 201) {
          this.messageService.add({
            severity: 'success',
            summary: this.translate.instant('requestForm.created'),
            detail: this.translate.instant('requestForm.created_message'),
          });
        } else {
          this.messageService.add({
            severity: 'error',
            summary: this.translate.instant('requestForm.error'),
            detail: this.translate.instant('requestForm.error_message'),
          });
        }
        return response;
      })
    );
  }

  deleteRequest(id: number): Observable<ApiResponseModel> {
    return this.api.deleteRequest(`api/request/${id}`).pipe(
      map((response: ApiResponseModel) => {
        if (response.status === 200) {
          this.messageService.add({
            severity: 'success',
            summary: this.translate.instant('global.success'),
            detail: this.translate.instant('request.delete_success'),
          });
        } else {
          this.messageService.add({
            severity: 'error',
            summary: this.translate.instant('global.error'),
            detail: this.translate.instant('request.delete_error'),
          });
        }
        return response;
      })
    );
  }

  updateRequest(id: number, request: FormData): Observable<ApiResponseModel> {
    return this.api.putRequest(`api/request/${id}`, {}, request).pipe(
      map((response: ApiResponseModel) => {
        if (response.status === 200) {
          this.messageService.add({
            severity: 'success',
            summary: this.translate.instant('global.success'),
            detail: this.translate.instant('requestForm.update_success'),
          });
        } else if (
          response.status === 422 &&
          response.errors['stl_file'] === 'must have .stl extension'
        ) {
          this.messageService.add({
            severity: 'error',
            summary: this.translate.instant('requestForm.upload_file'),
            detail: this.translate.instant('requestForm.file_type_error'),
          });
        } else if (
          response.status === 422 &&
          (response.errors['preset_requests.request_id'] ===
            'has already been taken' ||
            response.errors['base'] ===
              'Duplicate preset exists in the request')
        ) {
          this.messageService.add({
            severity: 'error',
            summary: this.translate.instant('requestForm.invalid_preset'),
            detail: this.translate.instant(
              'requestForm.invalid_preset_message'
            ),
          });
        } else {
          this.messageService.add({
            severity: 'error',
            summary: this.translate.instant('global.error'),
            detail: this.translate.instant('requestForm.update_error'),
          });
        }
        return response;
      })
    );
  }

  getStats(): Observable<RequestStatsModel[] | ApiResponseModel> {
    return this.api.getRequest('api/request', { type: 'stats' }).pipe(
      map((response: ApiResponseModel) => {
        if (response.status === 200) {
          return (response.data.stats as RequestStatsApi[])?.map(
            (statsData: RequestStatsApi) => {
              statsData.color_name = this.translationService.translateColor(
                statsData.color_id
              );

              statsData.filament_name =
                this.translationService.translateFilament(
                  statsData.filament_id
                );

              return RequestStatsModel.fromAPI(statsData);
            }
          );
        }
        return response;
      })
    );
  }
}
