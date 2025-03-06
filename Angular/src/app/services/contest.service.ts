import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { MessageService } from 'primeng/api';
import { map } from 'rxjs/operators';
import { TranslateService } from '@ngx-translate/core';

import { ApiResponseModel } from '../models/api-response.model';
import { ContestModel } from '../models/contest.model';
import { ApiRequestService } from './api.service';

@Injectable({
  providedIn: 'root'
})
export class ContestService {
  messageService: MessageService = inject(MessageService);
  translateService: TranslateService = inject(TranslateService);

  constructor(private api: ApiRequestService) { }

  getContests(params: any): Observable<ContestModel[]> {
    return this.api.getRequest('api/contest', params).pipe(
      map(response => {
        if (response.status === 200) {
          return response.data.contests.map((contest: any) => ContestModel.fromApi(contest));
        } else {
          this.messageService.add({ severity: 'error', summary: this.translateService.instant('global.errors.summary_error'), detail: this.translateService.instant('global.errors.gets_error') });
          return [];
        }
      })
    );
  }

  getContest(id: number): Observable<ContestModel | ApiResponseModel> {
    return this.api.getRequest(`api/contest/${id}`).pipe(
      map(response => {
        if (response.status === 200) {
          return ContestModel.fromApi(response.data.contest);
        } else {
          this.messageService.add({ severity: 'error', summary: this.translateService.instant('global.errors.summary_error'), detail: this.translateService.instant('global.errors.get_error') });
          return response;
        }
      })
    );
  }

  createContest(contest: FormData): Observable<ApiResponseModel> {
    return this.api.postRequest('api/contest', {}, contest).pipe(
      map(response => {
        if (response.status === 201) {
          this.messageService.add({ severity: 'success', summary: this.translateService.instant('global.errors.summary_success'), detail: this.translateService.instant('global.errors.created_success') });
        }
        else {
          this.messageService.add({ severity: 'error', summary: this.translateService.instant('global.errors.summary_error'), detail: this.translateService.instant('global.errors.created_error') });
        }
        return response;
      })
    );
  }

  updateContest(id: number, contest: FormData): Observable<ApiResponseModel> {
    return this.api.patchRequest(`api/contest/${id}`, {}, contest).pipe(
      map(response => {
        if (response.status === 200) {
          this.messageService.add({ severity: 'success', summary: this.translateService.instant('global.errors.summary_success'), detail: this.translateService.instant('global.errors.updated_success') });
        }
        else {
          this.messageService.add({ severity: 'error', summary: this.translateService.instant('global.errors.summary_error'), detail: this.translateService.instant('global.errors.updated_error') });
        }
        return response;
      })
    );
  }

  deleteContest(id: number): Observable<ApiResponseModel> {
    return this.api.deleteRequest(`api/contest/${id}`).pipe(
      map(response => {
        if (response.status === 200) {
          this.messageService.add({ severity: 'success', summary: this.translateService.instant('global.errors.summary_success'), detail: this.translateService.instant('global.errors.deleted_success') });
          }
          else {
            this.messageService.add({ severity: 'error', summary: this.translateService.instant('global.errors.summary_error'), detail: this.translateService.instant('global.errors.deleted_error') });
          }
        return response;
      })
    );
  }
}
