import { LikeModel, LikeAPI } from "./like.model";
import { UserApi, UserModel } from "./user.model";

export type SubmissionAPI = {
    id: number;
    user_id: number;
    contest_id: number;
    name: string;
    description: string | null;
    created_at: Date;
    updated_at: Date;
    image_url: string | null;
    stl_url: string;
    likes: LikeAPI[];
    liked_by_current_user: boolean;
    user: UserApi | null
}

export class SubmissionModel {
    id: number;
    user_id: number;
    contest_id: number;
    name: string;
    description: string | null;
    created_at: Date;
    updated_at: Date;
    imageUrl: string | null;
    stlUrl: string;
    likes: LikeModel[];
    liked: boolean = false;
    user: UserModel | null;

    constructor(
        id: number, 
        userId: number, 
        contestId: number, 
        name: string, 
        description: string | null, 
        createdAt: Date, 
        updatedAt: Date, 
        imageUrl: string | null, 
        stlUrl: string, 
        likes: LikeModel[], 
        user: UserModel | null,
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
        this.user = user;
        this.liked = liked;
    }

    static fromApi(data: SubmissionAPI): SubmissionModel {
        return new SubmissionModel(
            data?.id,
            data?.user_id,
            data?.contest_id,
            data?.name,
            data?.description,
            new Date(data?.created_at),
            new Date(data?.updated_at),
            data?.image_url,
            data?.stl_url,
            data?.likes?.map((like: LikeAPI) => new LikeModel(like?.id, like?.user_id, like?.submission_id)),
            data?.user ? UserModel.fromAPI(data?.user) : null,
            data?.liked_by_current_user
        );
    }
}
