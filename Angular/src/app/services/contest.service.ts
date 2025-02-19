import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { MessageService } from 'primeng/api';
import { map } from 'rxjs/operators';

import { ApiResponseModel } from '../models/api-response.model';
import { ContestModel } from '../models/contest.model';
import { ApiRequestService } from './api.service';

@Injectable({
  providedIn: 'root'
})
export class ContestService {
  messageService: MessageService = inject(MessageService);

  constructor(private api: ApiRequestService) { }

  getContests(): Observable<ContestModel[]> {
    return this.api.getRequest('api/contest').pipe(
      map(response => {
        if (response.status === 200) {
          return response.data.contests.map((contest: any) => ContestModel.fromApi(contest));
        } else {
          return [];
        }
      })
    );
  }

  getContest(id: number): Observable<ContestModel | null> {
    return this.api.getRequest(`api/contest/${id}`).pipe(
      map(response => {
        if (response.status === 200) {
          return ContestModel.fromApi(response.data.contest);
        } else {
          return null;
        }
      })
    );
  }

  createContest(contest: FormData): Observable<ApiResponseModel> {
    return this.api.postRequest('api/contest', {}, contest).pipe(
      map(response => {
        if (response.status === 201) {
          this.messageService.add({ severity: 'success', summary: 'Succès', detail: 'Concours créé avec succès' });
        }
        return response;
      })
    );
  }

  updateContest(id: number, contest: FormData): Observable<ApiResponseModel> {
    return this.api.patchRequest(`api/contest/${id}`, {}, contest).pipe(
      map(response => {
        if (response.status === 200) {
          this.messageService.add({ severity: 'success', summary: 'Succès', detail: 'Concours modifié avec succès' });
        }
        return response;
      })
    );
  }

  deleteContest(id: number): Observable<ApiResponseModel> {
    return this.api.deleteRequest(`api/contest/${id}`).pipe(
      map(response => {
        if (response.status === 200) {
          this.messageService.add({ severity: 'success', summary: 'Succès',
            detail: 'Concours supprimé avec succès' });
          }
        return response;
      })
    );
  }
}
