import { UserModel, UserApi } from "./user.model";
import { PrinterApi } from "./printer.model";
import { PrinterModel } from "./printer.model";

export type PrinterUserApi = {
    id: number;
    user: UserApi;
    printer: PrinterApi;
    acquired_date: Date;
    last_review_image: string | null;
    last_used: Date | null;
}

export class PrinterUserModel {
    id: number;
    user: UserModel;
    printer: PrinterModel;
    aquiredDate: Date;
    lastReviewedImage: string | null = null;
    lastUsed: Date | null = null;

    constructor(
        id: number,
        user: UserModel,
        printer: PrinterModel,
        acquiredDate: Date,
        lastReviewedImage: string | null,
        lastUsed: Date | null
    ) {
        this.id = id;
        this.user = user;
        this.printer = printer;
        this.aquiredDate = acquiredDate;
        this.lastReviewedImage = lastReviewedImage;
        this.lastUsed = lastUsed;
    }

    static fromAPI(data: PrinterUserApi): PrinterUserModel {
        return new PrinterUserModel(
            data.id,
            UserModel.fromAPI(data.user),
            PrinterModel.fromAPI(data.printer),
            new Date(data.acquired_date),
            data.last_review_image ?? null,
            data.last_used ? new Date(data.last_used) : null
        );
    }
}