import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { MessageService } from 'primeng/api';
import { map } from 'rxjs/operators';

import { ApiResponseModel } from '../models/api-response.model';
import { ContestModel } from '../models/contest.model';
import { ApiRequestService } from './api.service';
import { SubmissionModel } from '../models/submission.model';
import { UserSubmission } from '../models/user-submission';
import { UserContestSubmissionsModel } from '../models/user-contest-submissions.model';
import { TranslateService } from '@ngx-translate/core';



@Injectable({
  providedIn: 'root'
})
export class SubmissionService {
  messageService: MessageService = inject(MessageService);
  translateService: TranslateService = inject(TranslateService);

  constructor(private api: ApiRequestService) { }

  getSubmissions(contest_id: number): Observable<UserSubmission[]> {
    return this.api.getRequest(`api/contest/${contest_id}/user_submission`).pipe(
      map(response => {
        if (response.status === 200) {
          return response.data.submissions.map((submission: any) => UserSubmission.fromApi(submission));
        } else {
          this.messageService.add({ severity: 'error', summary: this.translateService.instant('global.errors.summary_error'), detail: this.translateService.instant('global.errors.gets_error') });
          return [];
        }
      })
    );
  }

  getUserContestSubmissions(user_id: number): Observable<UserContestSubmissionsModel[]> {
    return this.api.getRequest(`api/users/${user_id}/user_contest_submissions`).pipe(
      map(response => {
        if (response.status === 200) {
          return response.data.contests.map((data: any) => UserContestSubmissionsModel.fromApi(data));
        } else {
          this.messageService.add({ severity: 'error', summary: this.translateService.instant('global.errors.summary_error'), detail: this.translateService.instant('global.errors.gets_error') });
          return [];
        }
      })
    );
  }

  createSubmission(submission: FormData): Observable<ApiResponseModel> {
    return this.api.postRequest('api/submission', {}, submission).pipe(
      map(response => {
        if (response.status === 201) {
          this.messageService.add({
            severity: 'success', summary: this.translateService.instant('global.errors.summary_success'),
            detail: this.translateService.instant('global.errors.created_success')
          });
        }
        else {
          this.messageService.add({
            severity: 'error', summary: this.translateService.instant('global.errors.summary_error'),
            detail: this.translateService.instant('global.errors.created_error')
          });
        }
        return response;
      }
      )
    );
  }

  updateSubmission(submission: FormData, id: number): Observable<ApiResponseModel> {
    return this.api.putRequest(`api/submission/${id}`, {}, submission).pipe(
      map(response => {
        if (response.status === 200) {
          this.messageService.add({
            severity: 'success', summary: this.translateService.instant('global.errors.summary_success'),
            detail: this.translateService.instant('global.errors.updated_success')
          });
        }
        else {
          this.messageService.add({
            severity: 'error', summary: this.translateService.instant('global.errors.summary_error'),
            detail: this.translateService.instant('global.errors.updated_error')
          });
        }
        return response;
      }
      )
    );
  }

  deleteSubmission(id: number): Observable<ApiResponseModel> {
    return this.api.deleteRequest(`api/submission/${id}`).pipe(
      map(response => {
        if (response.status === 200) {
          this.messageService.add({
            severity: 'success', summary: this.translateService.instant('global.errors.summary_success'),
            detail: this.translateService.instant('global.errors.deleted_success')
          });
        }
        else {
          this.messageService.add({
            severity: 'error', summary: this.translateService.instant('global.errors.summary_error'),
            detail: this.translateService.instant('global.errors.deleted_error')
          });
        }
        return response;
      }
      )
    );
  }
}