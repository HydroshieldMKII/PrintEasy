import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable, of } from 'rxjs';
import { map, catchError, tap } from 'rxjs/operators';
import { ApiResponseModel } from '../models/api-response.model';

@Injectable({
    providedIn: 'root'
})

export class ApiRequestService {

    constructor(private http: HttpClient) { }

    getRequest(query: string, params?: { [key: string]: string }): Observable<ApiResponseModel> {
        return this.http.get<ApiResponseModel>(query, { params, observe: 'response' }).pipe(
            map(response => new ApiResponseModel(
                {
                    status: response.status,
                    errors: response.body?.errors ?? {}
                },
                response.body
            )),
            catchError((error: HttpErrorResponse) => this.handleHttpError(error))
        );
    }

    postRequest(query: string, params?: { [key: string]: any }, body?: any): Observable<ApiResponseModel> {
        return this.http.post<ApiResponseModel>(query, body, { params, observe: 'response' }).pipe(
            map(response => new ApiResponseModel(
                {
                    status: response.status,
                    errors: response.body?.errors ?? {}
                },
                response.body
            )),
            catchError((error: HttpErrorResponse) => this.handleHttpError(error))
        );
    }

    deleteRequest(query: string, params?: { [key: string]: string }): Observable<ApiResponseModel> {
        return this.http.delete<ApiResponseModel>(query, { params, observe: 'response' }).pipe(
            map(response => new ApiResponseModel(
                {
                    status: response.status,
                    errors: response.body?.errors ?? {}
                },
                response.body
            )),
            catchError((error: HttpErrorResponse) => this.handleHttpError(error))
        );
    }

    handleHttpError(error: HttpErrorResponse): Observable<ApiResponseModel> {
        let formattedErrors: { [key: string]: string } = {};

        if (error.error?.errors) {
            try {
                Object.keys(error.error.errors).forEach(key => {
                    formattedErrors[key] = error.error.errors[key].join(", ");
                });
            } catch (e) {
                formattedErrors["general"] = error.message || "An unexpected error occurred.";
            }
        } else {
            formattedErrors["general"] = error.message || "An unexpected error occurred.";
        }

        return of(new ApiResponseModel(
            {
                status: error.status || 500,
                errors: formattedErrors
            },
            {}
        ));

    }
}