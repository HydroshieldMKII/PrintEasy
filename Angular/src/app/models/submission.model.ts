import { LikeModel } from "./like.model";

export class SubmissionModel {
    id: number;
    user_id: number;
    contest_id: number;
    name: string;
    description: string | null;
    created_at: Date;
    updated_at: Date;
    imageUrl: string | null;
    stlUrl: string | null;
    likes: LikeModel[];
    liked: boolean = false;

    constructor(
        id: number, 
        userId: number, 
        contestId: number, 
        name: string, 
        description: string | null, 
        createdAt: Date, 
        updatedAt: Date, 
        imageUrl: string | null, 
        stlUrl: string | null, 
        likes: LikeModel[], 
        liked: boolean = false
    ) {
        this.id = id;
        this.user_id = userId;
        this.contest_id = contestId;
        this.name = name;
        this.description = description;
        this.created_at = createdAt;
        this.updated_at = updatedAt;
        this.imageUrl = imageUrl;
        this.stlUrl = stlUrl;
        this.likes = likes;
        this.liked = liked;
    }

    static fromApi(data: any): SubmissionModel {
        return new SubmissionModel(
            data?.['id'],
            data?.['user_id'],
            data?.['contest_id'],
            data?.['name'],
            data?.['description'],
            new Date(data?.['created_at']),
            new Date(data?.['updated_at']),
            data?.['image_url'],
            data?.['stl_url'],
            data?.['likes']?.map((like: any) => new LikeModel(like?.['id'], like?.['user_id'], like?.['submission_id'])),
            data?.['liked_by_current_user']
        );
    }
}
