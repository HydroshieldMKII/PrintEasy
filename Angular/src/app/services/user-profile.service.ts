import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { MessageService } from 'primeng/api';
import { map } from 'rxjs/operators';

import { UserModel } from '../models/user.model';
import { ApiResponseModel } from '../models/api-response.model';
import { ApiRequestService } from './api.service';
import { UserProfileModel } from '../models/user-profile.model';


@Injectable({
  providedIn: 'root'
})
export class UserProfileService {

  constructor(private api: ApiRequestService) { }

  getUserProfile(id: number): Observable<UserProfileModel | ApiResponseModel> {
    return this.api.getRequest(`/api/user_profile/${id}`).pipe(
      map((response: ApiResponseModel) => {
        if (response.status === 200) {
          return UserProfileModel.fromApi(response.data.user);
        } else {
          return response;
        }
      })
    );
  }
}
