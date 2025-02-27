import { ContestModel } from "./contest.model";
import { SubmissionModel } from "./submission.model";

export class UserContestSubmissionsModel {
    readonly contest: ContestModel;
    readonly submissions: SubmissionModel[];
    
    constructor(contest: ContestModel, submissions: SubmissionModel[]) {
        this.contest = contest;
        this.submissions = submissions;
    }

    static fromApi(data: any): UserContestSubmissionsModel {
        return new UserContestSubmissionsModel(
            ContestModel.fromApi(data.contest),
            data.submissions.map((submission: any) => SubmissionModel.fromApi(submission))
        );
    }
}
