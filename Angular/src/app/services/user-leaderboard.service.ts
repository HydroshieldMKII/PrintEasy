import { Injectable } from "@angular/core";
import { ApiRequestService } from "./api.service";
import { map, Observable } from "rxjs";
import { ApiResponseModel } from "../models/api-response.model";
import { UserLeaderboardModel, UserLeaderboardApi} from "../models/user-leaderboard.model";


@Injectable({
  providedIn: 'root'
})
export class UserLeaderboardService {

  constructor(private api: ApiRequestService) { }

  getUserLeaderboard(params: any): Observable<UserLeaderboardModel[]> {
    return this.api.getRequest('api/leaderboard', params).pipe(
      map(response => {
        if (response.status === 200) {
          return response.data.leaderboard.map((userLeaderboardApi: UserLeaderboardApi) => UserLeaderboardModel.fromApi(userLeaderboardApi));
        } else {
          return [];
        }
      })
    );
  }
}
