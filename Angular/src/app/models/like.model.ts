export type LikeAPI = {
    id: number;
    user_id: number;
    submission_id: number;
}

export class LikeModel {
    id: number;
    userId: number;
    submissionId: number;

    constructor(
        id: number, 
        userId: number, 
        submissionId: number
    ) {
        this.id = id;
        this.userId = userId;
        this.submissionId = submissionId;
    }

    static fromApi(data: any): LikeModel {
        return new LikeModel(
            data?.id,
            data?.user_id,
            data?.submission_id
        );
    }
}
