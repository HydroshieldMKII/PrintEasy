export type PrinterApi = {
    id: number;
    model: string;
}

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

    static fromAPI(data: any): PrinterModel | null {
        if (!data) {
            return null;
        }
        return new PrinterModel(
            data.id,
            data.model
        );
    }
}