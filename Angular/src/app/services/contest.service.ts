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

  createContest(contest: any): Observable<ApiResponseModel> {
    return this.api.postRequest('api/contest', contest).pipe(
      map(response => {
        if (response.status === 201) {
          this.messageService.add({ severity: 'success', summary: 'Succès', detail: 'Concours créé avec succès' });
        }
        return response;
      })
    );
  }
}
