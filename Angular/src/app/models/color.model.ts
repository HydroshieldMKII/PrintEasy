export type ColorApi = {
    id: number;
    name: string;
}

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

    static fromAPI(data: ColorApi): ColorModel {
        return new ColorModel(
            data.id,
            data.name
        );
    }

    static colorMap: Record<number, string> = {
        1: 'red',
        2: 'blue',
        3: 'green',
        4: 'yellow',
        5: 'black',
        6: 'white',
        7: 'orange',
        8: 'purple',
        9: 'pink',
        10: 'brown',
        11: 'gray'
    };
}