import { UserModel, UserApi } from "./user.model";
import { PrinterApi } from "./printer.model";
import { PrinterModel } from "./printer.model";

export type PrinterUserApi = {
    id: number;
    user: UserApi | null;
    printer: PrinterApi | null;
    aquired_date: Date;
}

export class PrinterUserModel {
    id: number;
    user: UserModel | null;
    printer: PrinterModel | null;
    aquiredDate: Date;

    constructor(
        id: number,
        user: UserModel | null,
        printer: PrinterModel | null,
        aquiredDate: Date
    ) {
        this.id = id;
        this.user = user;
        this.printer = printer;
        this.aquiredDate = aquiredDate;
    }

    static fromAPI(data: any): PrinterUserModel | null {
        if (!data) {
            return null;
        }
        return new PrinterUserModel(
            data.id,
            UserModel.fromAPI(data.user),
            PrinterModel.fromAPI(data.printer),
            new Date(data.aquired_date)
        );
    }
}