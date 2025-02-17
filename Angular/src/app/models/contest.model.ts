export class ContestModel {
    id: number;
    theme: string;
    description: string;
    submissionLimit: number;
    deleteAt?: Date | null;
    startAt: Date | null;
    endAt: Date | null;
    image: string | File;

    constructor(id: number, theme: string, description: string, submission_limit: number, start_at: Date, end_at: Date | null, image: string | File, deleted_at?: Date | null) {
        this.id = id;
        this.theme = theme;
        this.description = description;
        this.submissionLimit = submission_limit;
        this.startAt = start_at;
        this.endAt = end_at;
        this.deleteAt = deleted_at;
        this.image = image;
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
            data.deleted_at
        );
    }
}
