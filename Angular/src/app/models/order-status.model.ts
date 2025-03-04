export class OrderStatusModel {
    id: number;
    statusName: string;
    comment: string;
    createdAt: Date;
    updatedAt: Date;
    imageUrl: string;

    constructor(
        id: number, 
        status_name: string, 
        comment: string, 
        created_at: Date, 
        updated_at: Date, 
        image_url: string
    ) {
        this.id = id;
        this.statusName = status_name;
        this.comment = comment;
        this.createdAt = created_at;
        this.updatedAt = updated_at;
        this.imageUrl = image_url;
    }

    static fromAPI(data: any): OrderStatusModel | null {
        if (!data) {
            return null;
        }
        return new OrderStatusModel(
            data.id,
            data.status_name,
            data.comment,
            new Date(data.created_at),
            new Date(data.updated_at),
            data.image_url
        );
    }
}