import { UserModel, UserApi } from './user.model';
import { UserContestSubmissionsModel, UserContestSubmissionsAPI } from './user-contest-submissions.model';
import { PrinterUserModel, PrinterUserApi } from './printer-user.model';
import { ReviewApi, ReviewModel } from './review.model';
import { CountryModel, CountryApi } from './country.model';

export type UserProfileApi = {
    id: number;
    username: string;
    country: CountryApi;
    profile_picture_url: string | undefined;
    created_at: string;
    is_admin: boolean;
    printer_users: PrinterUserApi[] | null;
    user_contests_submissions: UserContestSubmissionsAPI[] | null;
    self_reviews: ReviewApi[] | null;
};

export class UserProfileModel {
    id: number;
    username: string;
    country: CountryApi;
    createdAt?: Date;
    profilePictureUrl?: string;
    isAdmin?: boolean;
    printerUsers: PrinterUserModel[];
    userContestSubmissions: UserContestSubmissionsModel[];
    selfReviews: ReviewModel[];
    
    constructor(
        id: number, 
        username: string, 
        country: CountryModel, 
        profilePictureUrl?: string, 
        createdAt?: Date, 
        isAdmin?: boolean,
        printerUsers?: PrinterUserModel[],
        userContestSubmissions?: UserContestSubmissionsModel[],
        selfReviews: ReviewModel[] = []
    ){
        this.id = id;
        this.username = username;
        this.country = country;
        this.createdAt = createdAt;
        this.profilePictureUrl = profilePictureUrl;
        this.isAdmin = isAdmin;
        this.printerUsers = printerUsers ?? [];
        this.userContestSubmissions = userContestSubmissions ?? [];
        this.selfReviews = selfReviews;
    }

    static fromApi(data: UserProfileApi): UserProfileModel {
        return new UserProfileModel(
            data.id,
            data.username,
            CountryModel.fromAPI(data.country),
            data.profile_picture_url,
            new Date(data.created_at),
            data.is_admin,
            data.printer_users?.map(printerUser => PrinterUserModel.fromAPI(printerUser)),
            data.user_contests_submissions?.map(submission => UserContestSubmissionsModel.fromApi(submission)),
            data.self_reviews?.map(review => ReviewModel.fromAPI(review))
        );
    }
}
