import { Like } from "./like";

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
    likes: Like[] | null;

    constructor(id: number, user_id: number, contest_id: number, name: string, description: string | null, created_at: Date, updated_at: Date, image_url: string | null, stl_url: string | null, likes: Like[] | null) {
        this.id = id;
        this.user_id = user_id;
        this.contest_id = contest_id;
        this.name = name;
        this.description = description;
        this.created_at = created_at;
        this.updated_at = updated_at;
        this.imageUrl = image_url;
        this.stlUrl = stl_url;
        this.likes = likes;
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
            data?.['likes']?.map((like: any) => new Like(like?.['id'], like?.['user_id'], like?.['submission_id']))
        );
    }
}
