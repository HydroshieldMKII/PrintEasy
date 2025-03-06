import { UserModel, UserApi } from './user.model';
import { UserContestSubmissionsModel, UserContestSubmissionsAPI } from './user-contest-submissions.model';
import { PrinterUserModel, PrinterUserApi } from './printer-user.model';

export type UserProfileApi = {
  user: UserApi;
};

export class UserProfileModel {
    user: UserModel;
    printerUsers: PrinterUserModel[];
    userContestSubmissions: UserContestSubmissionsModel[];
    
    constructor(
        user: UserModel,
        printerUsers: PrinterUserModel[],
        userContestSubmissions: UserContestSubmissionsModel[])
    {
        this.user = user;
        this.printerUsers = printerUsers;
        this.userContestSubmissions = userContestSubmissions;
    }

    static fromApi(data: UserProfileApi): UserProfileModel {
        return new UserProfileModel(
            UserModel.fromAPI(data.user),
            data.user.printer_users?.map(PrinterUserModel.fromAPI) ?? [],
            data.user.user_contests_submissions?.map(UserContestSubmissionsModel.fromApi) ?? []
        );
    }
}
