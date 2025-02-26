import { UserModel } from './user.model';

export class ContestModel {
    id: number;
    theme: string;
    description: string;
    submissionLimit: number;
    deleteAt: Date | null;
    startAt: Date;
    endAt: Date | null;
    image: string;
    finished: boolean;
    winnerUser: UserModel | null;

    constructor(id: number, theme: string, description: string, submission_limit: number, start_at: Date, end_at: Date | null, image: string, deleted_at: Date | null, finished: boolean, winnerUser: UserModel | null) {
        this.id = id;
        this.theme = theme;
        this.description = description;
        this.submissionLimit = submission_limit;
        this.startAt = start_at;
        this.endAt = end_at;
        this.deleteAt = deleted_at;
        this.image = image;
        this.finished = finished;
        this.winnerUser = winnerUser;
    }

    static fromApi(data: any): ContestModel {
        return new ContestModel(
            data.id,
            data.theme,
            data.description,
            data.submission_limit,
            data.start_at,
            data.end_at,
            data.image_url,
            data.deleted_at,
            data.finished,
            data.winner_user ? UserModel.fromAPI(data.winner_user) : null
        );
    }

    static toApi(data: any): any {
        return {
            contest:
            {
                theme: data.theme,
                description: data.description,
                submission_limit: data.submissionLimit,
                start_at: data.startAt,
                end_at: data.endAt,
                image: data.image
            }
        };
    }
}
