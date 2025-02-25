export class FilamentModel {
    id: number;
    name: string;

    constructor(id: number, name: string) {
        this.id = id;
        this.name = name;
    }

    static fromAPI(data: any): FilamentModel {
        return new FilamentModel(
            data.id,
            data.name
        );
    }
}