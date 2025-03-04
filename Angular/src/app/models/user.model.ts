export class UserModel {
    id: number;
    username: string;
    country: string;
    createdAt?: Date;
    profilePictureUrl?: string;
    isAdmin?: boolean;

    constructor(
        id: number, 
        username: string, 
        country: string, 
        profilePictureUrl?: string, 
        createdAt?: Date, 
        isAdmin?: boolean
    ) {
        this.id = id;
        this.username = username;
        this.country = country;
        this.createdAt = createdAt;
        this.profilePictureUrl = profilePictureUrl;
        this.isAdmin = isAdmin;
    }

    static fromAPI(data: any): UserModel | null {
        if (!data) {
            return null;
        }
        return new UserModel(
            data.id,
            data.username,
            data.country,
            data.profile_picture_url,
            new Date(data.created_at),
            data.is_admin
        );
    }
}
