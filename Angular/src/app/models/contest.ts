export class Contest {
    id: number;
    theme: string;
    description: string;
    submissionLimit: number;
    deleteAt?: Date | null;
    startAt: Date | null;
    endAt: Date | null;

    constructor(id: number, theme: string, description: string, submission_limit: number, start_at: Date | null, end_at: Date | null, deleted_at?: Date | null) {
        this.id = id;
        this.theme = theme;
        this.description = description;
        this.submissionLimit = submission_limit;
        this.startAt = start_at;
        this.endAt = end_at;
        this.deleteAt = deleted_at;
    }
}
