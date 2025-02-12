export class UserCredentialsModel {
    readonly username: string
    readonly password: string
    readonly confirmPassword: string

    constructor(username: string, password: string, confirmPassword?: string) {
        this.username = username.toLowerCase()
        this.password = password
        this.confirmPassword = password
    }

}