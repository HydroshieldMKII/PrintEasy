import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { MessageService } from 'primeng/api';
import { map } from 'rxjs/operators';

import { UserModel } from '../models/user.model';
import { ApiResponseModel } from '../models/api-response.model';
import { ApiRequestService } from './api.service';


@Injectable({
  providedIn: 'root'
})
export class UserProfileService {

  constructor(private api: ApiRequestService) { }

  getUserProfile(id: number): Observable<UserModel | ApiResponseModel> {
    return this.api.getRequest(`/api/user_profile/${id}`).pipe(
      map((response: ApiResponseModel) => {
        if (response.status === 200) {
          console.log(response);
          return UserModel.fromAPI(response.data.user);
        } else {
          return response;
        }
      })
    );
  }
}
