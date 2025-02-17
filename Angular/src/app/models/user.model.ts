export class UserModel {
    id: number;
    username: string;
    country: string;

    constructor(id: number, username: string, country: string) {
        this.id = id;
        this.username = username;
        this.country = country;
    }
}
