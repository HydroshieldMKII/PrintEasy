import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { inject, Injectable, Injector } from '@angular/core';
import { Observable, of } from 'rxjs';
import { map, catchError, tap } from 'rxjs/operators';
import { ApiResponseModel } from '../models/api-response.model';
import { AuthService } from './authentication.service';
import { Router } from '@angular/router';

@Injectable({
    providedIn: 'root'
})

export class ApiRequestService {
    constructor(private http: HttpClient, private router: Router, private injector: Injector) { }

    getRequest(query: string, params?: { [key: string]: string }): Observable<ApiResponseModel> {
        return this.http.get<ApiResponseModel>(query, { params, observe: 'response' }).pipe(
            map(response => {
                return new ApiResponseModel(
                    {
                        status: response.status,
                        errors: response.body?.errors ?? {}
                    },
                    response.body
                );
            }),
            catchError((error: HttpErrorResponse) => {
                return this.handleHttpError(error);
            })
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
            catchError((error: HttpErrorResponse) => {
                return this.handleHttpError(error);
            }),
        );
    }

    putRequest(query: string, params?: { [key: string]: any }, body?: any): Observable<ApiResponseModel> {
        return this.http.put<ApiResponseModel>(query, body, { params, observe: 'response' }).pipe(
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

    patchRequest(query: string, params?: { [key: string]: any }, body?: any): Observable<ApiResponseModel> {
        return this.http.patch<ApiResponseModel>(query, body, { params, observe: 'response' }).pipe(
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

        if (error.status === 401) {
            // const authService = this.injector.get(AuthService);
            // authService.logOut();
            this.router.navigate(['/login']);
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