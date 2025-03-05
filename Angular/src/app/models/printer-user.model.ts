import { UserModel, UserApi } from "./user.model";
import { PrinterApi } from "./printer.model";
import { PrinterModel } from "./printer.model";
import { FormGroup } from "@angular/forms";

export type PrinterUserApi = {
    id: number;
    user: UserApi;
    printer: PrinterApi;
    acquired_date: Date;
    last_review_image: string | null;
    last_used: Date | null;
    can_delete: boolean | null;
}

export class PrinterUserModel {
    id: number;
    user: UserModel;
    printer: PrinterModel;
    aquiredDate: Date;
    lastReviewedImage: string | null = null;
    lastUsed: Date | null = null;
    canDelete: boolean | null = null;

    constructor(
        id: number,
        user: UserModel,
        printer: PrinterModel,
        acquiredDate: Date,
        lastReviewedImage: string | null,
        lastUsed: Date | null,
        canDelete: boolean | null = null
    ) {
        this.id = id;
        this.user = user;
        this.printer = printer;
        this.aquiredDate = acquiredDate;
        this.lastReviewedImage = lastReviewedImage;
        this.lastUsed = lastUsed;
        this.canDelete = canDelete;
    }

    static fromAPI(data: PrinterUserApi): PrinterUserModel {
        return new PrinterUserModel(
            data.id,
            UserModel.fromAPI(data.user),
            PrinterModel.fromAPI(data.printer),
            new Date(data.acquired_date + 'T00:00:00'),
            data.last_review_image ?? null,
            data.last_used ? new Date(data.last_used) : null,
            data.can_delete ?? null
        );
    }

    static toAPI(printerUserForm: FormGroup): FormData {
        const printerUserFormData = new FormData();

        printerUserFormData.append('printer_user[printer_id]', printerUserForm.value.printer.id);
        printerUserFormData.append('printer_user[acquired_date]', printerUserForm.value.aquiredDate);
        console.log("PrinterUserFormDate:", printerUserFormData);
        return printerUserFormData;
    }
}