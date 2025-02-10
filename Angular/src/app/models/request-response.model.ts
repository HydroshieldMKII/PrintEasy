export class RequestResponseModel {
    readonly status: number
    readonly errors: { [key: string]: string }
    readonly data: string

    constructor(value: { status: number, errors: { [key: string]: string } }, data: string) {
        this.status = value.status
        this.errors = value.errors
        this.data = data
    }
}