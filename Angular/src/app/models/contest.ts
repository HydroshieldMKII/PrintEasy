export class Contest {
    id: number;
    theme: string;
    description: string;
    submission_limit: number;
    deleted_at?: Date | null;
    start_at: Date | null;
    end_at: Date | null;

    constructor(id: number, theme: string, description: string, submission_limit: number, start_at: Date | null, end_at: Date | null, deleted_at?: Date | null) {
        this.id = id;
        this.theme = theme;
        this.description = description;
        this.submission_limit = submission_limit;
        this.start_at = start_at;
        this.end_at = end_at;
        this.deleted_at = deleted_at;
    }
}
