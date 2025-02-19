export class OrderStatusModel {
    id: number;
    status_name: string;
    comment: string;
    created_at: Date;
    updated_at: Date;

    constructor(id: number, status_name: string, comment: string, created_at: Date, updated_at: Date) {
        this.id = id;
        this.status_name = status_name;
        this.comment = comment;
        this.created_at = created_at;
        this.updated_at = updated_at;
    }
}