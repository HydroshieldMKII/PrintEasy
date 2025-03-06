import { CountryApi, CountryModel } from './country.model';
import { PrinterUserApi, PrinterUserModel } from './printer-user.model';
import { UserContestSubmissionsAPI, UserContestSubmissionsModel } from './user-contest-submissions.model';

export type UserApi = {
    id: number;
    username: string;
    country: CountryApi;
    profile_picture_url: string | undefined;
    created_at: string;
    is_admin: boolean;
    printer_users: PrinterUserApi[] | null;
    user_contests_submissions: UserContestSubmissionsAPI[] | null;
}

export class UserModel {
    id: number;
    username: string;
    country: CountryModel;
    createdAt?: Date;
    profilePictureUrl?: string;
    isAdmin?: boolean;
    printerUsers?: PrinterUserModel[];
    userContestSubmissions?: UserContestSubmissionsModel[];


    constructor(
        id: number, 
        username: string, 
        country: CountryModel, 
        profilePictureUrl?: string, 
        createdAt?: Date, 
        isAdmin?: boolean,
        printerUsers?: PrinterUserModel[],
        userContestSubmissions?: UserContestSubmissionsModel[]
    ) {
        this.id = id;
        this.username = username;
        this.country = country;
        this.createdAt = createdAt;
        this.profilePictureUrl = profilePictureUrl;
        this.isAdmin = isAdmin;
        this.printerUsers = printerUsers;
        this.userContestSubmissions = userContestSubmissions;
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
