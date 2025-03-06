import { CountryApi, CountryModel } from './country.model';
import { PrinterUserApi, PrinterUserModel } from './printer-user.model';
import { ReviewApi } from './review.model';
import { UserContestSubmissionsAPI, UserContestSubmissionsModel } from './user-contest-submissions.model';

export type UserApi = {
    id: number;
    username: string;
    country: CountryApi;
    profile_picture_url: string | undefined;
    created_at: string;
    is_admin: boolean;
}

export class UserModel {
    id: number;
    username: string;
    country: CountryModel;
    createdAt?: Date;
    profilePictureUrl?: string;
    isAdmin?: boolean;


    constructor(
        id: number, 
        username: string, 
        country: CountryModel, 
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

    static fromAPI(data: UserApi): UserModel {
        return new UserModel(
            data.id,
            data.username,
            CountryModel.fromAPI(data.country),
            data.profile_picture_url,
            new Date(data.created_at),
            data.is_admin
        );
    }
}
