export class LikeModel {
    id: number;
    userId: number;
    submissionId: number;

    constructor(id: number, user_id: number, submission_id: number) {
        this.id = id;
        this.userId = user_id;
        this.submissionId = submission_id;
    }

    static fromApi(data: any): LikeModel {
        return new LikeModel(
            data?.['id'],
            data?.['user_id'],
            data?.['submission_id']
        );
    }
}
