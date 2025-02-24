import { UserModel } from './user.model';

export class ReviewModel {
    id: number;
    title: string;
    description: string;
    rating: number;
    createdAt: Date;
    user: UserModel;

    constructor(id: number, rating: number, title: string, description: string, user: UserModel, created_at: Date) {
        this.id = id;
        this.title = title;
        this.rating = rating;
        this.description = description;
        this.user = user;
        this.createdAt = created_at;
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
            UserModel.fromAPI(data.user),
            new Date(data.created_at)
        );
    }
}