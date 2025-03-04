import { UserModel } from './user.model';
import { ImageAttachmentModel, ImageAttachmentApi } from './image-attachment.model';
import { UserApi } from './user.model';

export type ReviewApi = {
    id: number;
    rating: number;
    title: string;
    description: string;
    created_at: string;
    image_urls: ImageAttachmentApi[];
    user: UserApi;
}

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
        createdAt: Date, 
        imageUrls: ImageAttachmentModel[] = [], 
        user: UserModel | null
    ) {
        this.id = id;
        this.title = title;
        this.rating = rating;
        this.description = description;
        this.user = user;
        this.createdAt = createdAt;
        this.imageUrls = imageUrls;
    }

    static fromAPI(data: any): ReviewModel {
        return new ReviewModel(
            data.id,
            data.rating,
            data.title,
            data.description,
            new Date(data.created_at),
            (data.image_urls ?? []).map((image: ImageAttachmentApi) => ImageAttachmentModel.fromAPI(image)),
            UserModel.fromAPI(data.user)
        );
    }
}