import { SubmissionModel } from './submission.model';
import { UserModel } from './user.model';

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

    static fromApi(data: any): UserSubmission {
        console.log('UserSubmission:', data);
        return new UserSubmission(
            new UserModel(
                data?.['user']?.['id'],
                data?.['user']?.['username'],
                data?.['user']?.['country'],
                data?.['user']?.['profile_picture_url'],
                new Date(data?.['user']?.['created_at']),
                data?.['user']?.['isAdmin']
            ),
            data?.['submissions']?.map((submission: any) => SubmissionModel.fromApi(submission)),
            data?.['mine']
        );
    }
}
