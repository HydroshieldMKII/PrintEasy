import { Injectable } from "@angular/core";
import { ApiRequestService } from "./api.service";
import { map, Observable } from "rxjs";
import { ApiResponseModel } from "../models/api-response.model";
import { ContestAPI, ContestModel } from "../models/contest.model";
import { RequestApi, RequestModel } from "../models/request.model";
import { SubmissionAPI, SubmissionModel } from "../models/submission.model";

export type HomeApi = {
    contests: ContestAPI[],
    requests: RequestApi[],
    submissions: SubmissionAPI[]
}

@Injectable({
    providedIn: 'root'
})
export class HomeService {
    constructor(private api: ApiRequestService) { }

    getData(): Observable<HomeApi | ApiResponseModel> {
        return this.api.getRequest('/api/home').pipe(
            map((response : ApiResponseModel) => {
                
                if (response.status == 200) {
                    return {
                        contests: response.data.contests.map((contest: ContestAPI) => ContestModel.fromApi(contest)),
                        requests: response.data.requests.map((request: RequestApi) => RequestModel.fromAPI(request)),
                        submissions: response.data.submissions.map((submission: SubmissionAPI) => SubmissionModel.fromApi(submission))
                    };
                }
                return response;
            })
        );
    }
}