import { UserModel } from "./user.model";
import { PrinterModel } from "./printer.model";

export class PrinterUserModel {
    id: number;
    user: UserModel | null;
    printer: PrinterModel | null;
    aquiredDate: Date;

    constructor(
        id: number,
        user: UserModel | null,
        printer: PrinterModel | null,
        aquired_date: Date
    ) {
        this.id = id;
        this.user = user;
        this.printer = printer;
        this.aquiredDate = aquired_date;
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