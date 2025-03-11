import { Injectable } from '@angular/core';
import { ApiRequestService } from './api.service';
import { Observable } from 'rxjs';
import { ApiResponseModel } from '../models/api-response.model';
import { map } from 'rxjs/operators';
import { LikeModel } from '../models/like.model';
import { SubmissionModel, SubmissionAPI } from '../models/submission.model';


@Injectable({
  providedIn: 'root'
})
export class LikeService {

  constructor(private api: ApiRequestService) { }

  getLikes(): Observable<SubmissionModel[]> {
    return this.api.getRequest('api/like').pipe(
      map(response => {
        if (response.status === 200) {
          return response.data.likes.map((submission: SubmissionAPI) => SubmissionModel.fromApi(submission));
        }
        else {
          return [];
        }

      })
    );
  }

  createLike(submissionId: number): Observable<ApiResponseModel> {
    return this.api.postRequest('api/like', {}, { submission_id: submissionId }).pipe(
      map(response => {
        return response;
      })
    );
  }

  deleteLike(id: number = 0): Observable<ApiResponseModel> {
    return this.api.deleteRequest(`api/like/${id}`).pipe(
      map(response => {
        return response;
      })
    );
  }
}
