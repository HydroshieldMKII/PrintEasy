export class UserModel {
    id: number;
    username: string;
    country: string;
    createdAt?: Date;
    isAdmin?: boolean;

    constructor(id: number, username: string, country: string, createdAt?: Date, isAdmin?: boolean) {
        this.id = id;
        this.username = username;
        this.country = country;
        this.createdAt = createdAt;
        this.isAdmin = isAdmin;
    }
}
