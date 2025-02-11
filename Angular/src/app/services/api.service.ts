import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable, of } from 'rxjs';
import { map, catchError, tap } from 'rxjs/operators';
import { RequestResponseModel } from '../models/request-response.model';

@Injectable({
    providedIn: 'root'
})

export class ApiRequestService {

    constructor(private http: HttpClient) { }

    getRequest(query: string, params?: { [key: string]: string }): Observable<RequestResponseModel> {
        return this.http.get<RequestResponseModel>(query, { params, observe: 'response' }).pipe(
            map(response => new RequestResponseModel(
                {
                    status: response.status,
                    errors: response.body?.errors ?? {}
                },
                response.body?.data ?? ""
            )),
            catchError((error: HttpErrorResponse) => this.handleHttpError(error))
        );
    }

    postRequest(query: string, params?: { [key: string]: any }, body?: any): Observable<RequestResponseModel> {
        return this.http.post<RequestResponseModel>(query, body, { params, observe: 'response' }).pipe(
            map(response => new RequestResponseModel(
                {
                    status: response.status,
                    errors: response.body?.errors ?? {}
                },
                response.body?.data ?? ""
            )),
            catchError((error: HttpErrorResponse) => this.handleHttpError(error))
        );
    }

    handleHttpError(error: HttpErrorResponse): Observable<RequestResponseModel> {
        let formattedErrors: { [key: string]: string } = {};

        if (error.error?.errors) {
            // Convert error array messages into a single string per field
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

        return of(new RequestResponseModel(
            {
                status: error.status || 500,
                errors: formattedErrors
            },
            ""
        ));

    }
}