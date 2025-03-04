import { SubmissionModel, SubmissionAPI } from './submission.model';
import { UserModel, UserApi } from './user.model';

export type UserSubmissionAPI = {
    user: UserApi;
    submissions: SubmissionAPI[];
    mine: boolean;
}

export class UserSubmission {
    user: UserModel;
    submissions: SubmissionModel[];
    mine: boolean;

    constructor(
        user: UserModel, 
        submissions: SubmissionModel[], 
        mine: boolean
    ) {
        this.user = user;
        this.submissions = submissions;
        this.mine = mine;
    }

    static fromApi(data: UserSubmissionAPI): UserSubmission {
        console.log('UserSubmission:', data);
        return new UserSubmission(
            UserModel.fromAPI(data?.user),
            data?.submissions?.map((submission: SubmissionAPI) => SubmissionModel.fromApi(submission)),
            data?.mine
        );
    }
}
