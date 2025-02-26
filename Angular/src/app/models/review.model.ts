import { UserModel } from './user.model';

export class ReviewModel {
    id: number;
    title: string;
    description: string;
    rating: number;
    createdAt: Date;
    user?: UserModel;
    imageUrls: string[] = [];

    constructor(id: number, rating: number, title: string, description: string, created_at: Date, image_urls: string[] = [], user?: UserModel) {
        this.id = id;
        this.title = title;
        this.rating = rating;
        this.description = description;
        this.user = user;
        this.createdAt = created_at;
        this.imageUrls = image_urls;
    }

    static fromAPI(data: any): ReviewModel | null {
        if (!data) {
            return null;
        }
        return new ReviewModel(
            data.id,
            data.rating,
            data.title,
            data.description,
            new Date(data.created_at),
            data.image_urls,
            UserModel.fromAPI(data.user)
        );
    }
}