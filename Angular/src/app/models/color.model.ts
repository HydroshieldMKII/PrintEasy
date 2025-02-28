export class ColorModel {
    id: number;
    name: string;

    constructor(
        id: number,
        name: string
    ) {
        this.id = id;
        this.name = name;
    }

    static fromAPI(data: any): ColorModel | null {
        if (!data) {
            return null;
        }
        return new ColorModel(
            data.id,
            data.name
        );
    }
}