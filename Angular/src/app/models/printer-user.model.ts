import { UserModel } from "./user.model";
import { PrinterModel } from "./printer.model";

export class PrinterUserModel {
    id: number;
    user: UserModel;
    printer: PrinterModel;
    aquired_date: Date;

    constructor(
        id: number,
        user: UserModel,
        printer: PrinterModel,
        aquired_date: Date
    ) {
        this.id = id;
        this.user = user;
        this.printer = printer;
        this.aquired_date = aquired_date;
    }
}