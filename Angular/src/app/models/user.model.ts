export class UserModel {
    id: number;
    username: string;
    country: string;
    createdAt?: Date;
    profile_picture_url?: string;

    constructor(id: number, username: string, country: string, profile_picture_url?: string, createdAt?: Date) {
        this.id = id;
        this.username = username;
        this.country = country;
        this.createdAt = createdAt;
        this.profile_picture_url = profile_picture_url;
    }
}
