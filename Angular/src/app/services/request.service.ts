import { inject, Injectable } from '@angular/core';
import { RequestModel, RequestApi } from '../models/request.model';
import {
  RequestPresetApi,
  RequestPresetModel,
} from '../models/request-preset.model';
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
  providedIn: 'root',
})
export class RequestService {
  messageService: MessageService = inject(MessageService);
  requests: RequestModel[] = [];

  constructor(
    private api: ApiRequestService,
    private translate: TranslateService
  ) {}

  filter(
    filterParams: string,
    sortCategory: string,
    orderParams: string,
    searchParams: string,
    minBudget: number | null,
    maxBudget: number | null,
    startDate: Date,
    endDate: Date,
    type: string
  ): Observable<[RequestModel[], boolean] | ApiResponseModel> {
    const params: any = {};

    if (filterParams) params.filter = filterParams;
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

    return this.fetchRequests(params);
  }

  getRequestById(id: number): Observable<RequestModel | ApiResponseModel> {
    return this.api.getRequest(`api/request/${id}`).pipe(
      map((response: ApiResponseModel) => {
        if (response.status === 200) {
          response.data.request.preset_requests.map(
            (preset: RequestPresetApi) => {
              preset.color.name = this.translateColor(preset.color.id);
              preset.filament.name = this.translateFilament(preset.filament.id);
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
                preset.color.name = this.translateColor(preset.color.id);
                preset.filament.name = this.translateFilament(
                  preset.filament.id
                );
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

  private translateFilament(id: number): string {
    const key = FilamentModel.filamentMap[id];
    return key
      ? this.translate.instant(`materials.${key}`)
      : `Unknown Filament (${id})`;
  }

  private translateColor(id: number): string {
    const key = ColorModel.colorMap[id];
    return key
      ? this.translate.instant(`colors.${key}`)
      : `Unknown Color (${id})`;
  }
}
