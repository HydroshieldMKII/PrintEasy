export class UserCredentialsModel {
    readonly username: string
    readonly password: string

    constructor(value: { username: string, password: string }) {
        this.username = value.username.toLowerCase()
        this.password = value.password
    }

}