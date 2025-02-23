import { SubmissionModel } from './submission.model';

export class UserSubmission {
    id: number;
    username: string;
    submissions: SubmissionModel[];

    constructor(id: number, username: string, submissions: SubmissionModel[]) {
        this.id = id;
        this.username = username;
        this.submissions = submissions;
    }

    static fromApi(data: any): UserSubmission {
        return new UserSubmission(
            data?.['id'],
            data?.['username'],
            data?.['submissions']?.map((submission: any) => SubmissionModel.fromApi(submission))
        );
    }
}
