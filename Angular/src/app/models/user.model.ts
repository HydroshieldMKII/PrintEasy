export class UserModel {
    id: number;
    username: string;
    country: string;
    createdAt?: Date;

    constructor(id: number, username: string, country: string, createdAt?: Date) {
        this.id = id;
        this.username = username;
        this.country = country;
        this.createdAt = createdAt;
    }
}
