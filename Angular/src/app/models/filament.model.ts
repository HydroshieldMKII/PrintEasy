export type FilamentApi = {
    id: number;
    name: string;
}

export class FilamentModel {
    id: number;
    name: string;

    filamentMap: Record<number, string> = {
        1: 'petg',
        2: 'tpu',
        3: 'nylon',
        4: 'wood',
        5: 'metal',
        6: 'carbon_fiber'
    };

    constructor(
        id: number,
        name: string
    ) {
        this.id = id;
        this.name = name;
    }

    static fromAPI(data: FilamentApi): FilamentModel {
        return new FilamentModel(
            data.id,
            data.name
        );
    }
}