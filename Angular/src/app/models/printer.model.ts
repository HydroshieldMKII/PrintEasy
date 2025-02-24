export class PrinterModel {
    id: number;
    model: string;

    constructor(
        id: number,
        model: string
    ) {
        this.id = id;
        this.model = model;
    }

    static fromAPI(data: any): PrinterModel {
        return new PrinterModel(
            data.id,
            data.model
        );
    }
}