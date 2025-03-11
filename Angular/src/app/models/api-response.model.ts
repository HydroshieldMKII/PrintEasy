export class ApiResponseModel {
    readonly status: number
    readonly errors: { [key: string]: string }
    readonly data: any

    constructor(
        value: { 
            status: number, 
            errors: { [key: string]: string } 
        }, 
        data: any
    ) {
        this.status = value.status
        this.errors = value.errors
        this.data = data
    }
}