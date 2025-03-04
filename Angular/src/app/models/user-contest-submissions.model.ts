import { ContestModel, ContestAPI } from "./contest.model";
import { SubmissionModel, SubmissionAPI } from "./submission.model";

export type UserContestSubmissionsAPI = {
    contest: ContestAPI;
    submissions: SubmissionAPI[];
}

export class UserContestSubmissionsModel {
    readonly contest: ContestModel;
    readonly submissions: SubmissionModel[];
    
    constructor(
        contest: ContestModel, 
        submissions: SubmissionModel[]
    ) {
        this.contest = contest;
        this.submissions = submissions;
    }

    static fromApi(data: UserContestSubmissionsAPI): UserContestSubmissionsModel {
        return new UserContestSubmissionsModel(
            ContestModel.fromApi(data.contest),
            data.submissions.map((submission: SubmissionAPI) => SubmissionModel.fromApi(submission))
        );
    }
}
