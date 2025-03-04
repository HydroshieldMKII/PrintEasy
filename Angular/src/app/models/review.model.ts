import { UserModel } from './user.model';
import { ImageAttachmentModel } from './image-attachment.model';

export class ReviewModel {
    id: number;
    title: string;
    description: string;
    rating: number;
    createdAt: Date;
    user: UserModel | null;
    imageUrls: ImageAttachmentModel[] = [];

    constructor(
        id: number, 
        rating: number, 
        title: string, 
        description: string, 
        created_at: Date, 
        image_urls: ImageAttachmentModel[] = [], 
        user: UserModel | null
    ) {
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
            (data.image_urls ?? []).map((image: any) => ImageAttachmentModel.fromAPI(image)),
            UserModel.fromAPI(data.user)
        );
    }
}