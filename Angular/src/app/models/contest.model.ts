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
    started: boolean;

    constructor(
        id: number, 
        theme: string, 
        description: string, 
        submissionLimit: number, 
        startAt: Date, 
        endAt: Date | null, 
        image: string, 
        deletedAt: Date | null, 
        finished: boolean, 
        winnerUser: UserModel | null, 
        started: boolean
    ) {
        this.id = id;
        this.theme = theme;
        this.description = description;
        this.submissionLimit = submissionLimit;
        this.startAt = startAt;
        this.endAt = endAt;
        this.deleteAt = deletedAt;
        this.image = image;
        this.finished = finished;
        this.winnerUser = winnerUser;
        this.started = started;
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
            data['finished?'],
            data.winner_user ? UserModel.fromAPI(data.winner_user) : null,
            data['started?']
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
