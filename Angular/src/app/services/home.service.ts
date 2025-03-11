import { Injectable } from "@angular/core";
import { ApiRequestService } from "./api.service";
import { map, Observable } from "rxjs";
import { ApiResponseModel } from "../models/api-response.model";
import { ContestAPI, ContestModel } from "../models/contest.model";
import { RequestApi, RequestModel } from "../models/request.model";
import { SubmissionAPI, SubmissionModel } from "../models/submission.model";

export type HomeApi = {
    contests: ContestAPI[];
    requests: RequestApi[];
    submissions: SubmissionAPI[];
}

export class HomeModel {
    contests: ContestModel[];
    requests: RequestModel[];
    submissions: SubmissionModel[];

    constructor(
        contests: ContestModel[], 
        requests: RequestModel[], 
        submissions: SubmissionModel[]
    ) {
        this.contests = contests;
        this.requests = requests;
        this.submissions = submissions;
    }

    static fromAPI(api: HomeApi): HomeModel {
        return new HomeModel(
            api.contests.map((contest: ContestAPI) => ContestModel.fromApi(contest)),
            api.requests.map((request: RequestApi) => RequestModel.fromAPI(request)),
            api.submissions.map((submission: SubmissionAPI) => SubmissionModel.fromApi(submission))
        );
    }
}

@Injectable({
    providedIn: 'root'
})
export class HomeService {
    constructor(private api: ApiRequestService) { }

    getData(): Observable<HomeModel | ApiResponseModel> {
        return this.api.getRequest('/api/home').pipe(
            map((response : ApiResponseModel) => {

                if (response.status == 200) {
                    return HomeModel.fromAPI(response.data as HomeApi);
                }
                return response;
            })
        );
    }
}