export type CountryApi = {
    id: number;
    name: string;
}

export class CountryModel {
    id: number;
    name: string;

    constructor(
        id: number, 
        name: string
    ) {
        this.id = id;
        this.name = name;
    }

    static fromAPI(data: CountryApi): CountryModel {
        return new CountryModel(
            data.id,
            data.name
        );
    }
}