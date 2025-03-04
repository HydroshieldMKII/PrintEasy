export type OrderStatusApi = {
    id: number;
    status_name: string;
    comment: string;
    created_at: string;
    updated_at: string;
    image_url: string;
}

export class OrderStatusModel {
    id: number;
    statusName: string;
    comment: string;
    createdAt: Date;
    updatedAt: Date;
    imageUrl: string;

    constructor(
        id: number, 
        statusName: string, 
        comment: string, 
        createdAt: Date, 
        updatedAt: Date, 
        imageUrl: string
    ) {
        this.id = id;
        this.statusName = statusName;
        this.comment = comment;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.imageUrl = imageUrl;
    }

    static fromAPI(data: OrderStatusApi): OrderStatusModel {
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