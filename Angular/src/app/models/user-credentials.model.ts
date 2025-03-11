export class UserCredentialsModel {
    readonly username: string
    readonly password: string
    readonly confirmPassword?: string
    readonly countryId?: number

    constructor(
        username: string, 
        password: string, 
        confirmPassword?: string, 
        countryId?: number
    ) {
        this.username = username.toLowerCase()
        this.password = password
        this.confirmPassword = password
        this.countryId = countryId
    }
}
