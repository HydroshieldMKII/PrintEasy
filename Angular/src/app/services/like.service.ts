import { Injectable } from '@angular/core';
import { ApiRequestService } from './api.service';
import { Observable } from 'rxjs';
import { ApiResponseModel } from '../models/api-response.model';
import { map } from 'rxjs/operators';
import { LikeModel } from '../models/like.model';


@Injectable({
  providedIn: 'root'
})
export class LikeService {

  constructor(private api: ApiRequestService) { }

  createLike(submissionId: number): Observable<ApiResponseModel> {
    return this.api.postRequest('api/like', {}, { submission_id: submissionId }).pipe(
      map(response => {
        if (response.status === 201) {
          console.log('response:', response);
        }
        else {
          console.log('error:', response.errors);
        }

        return response;
      })
    );
  }

  deleteLike(id: number = 0): Observable<ApiResponseModel> {
    return this.api.deleteRequest(`api/like/${id}`).pipe(
      map(response => {
        if (response.status === 200) {
          console.log('response:', response);
        }
        else {
          console.log('error:', response.errors);
        }

        return response;
      })
    );
  }
}
