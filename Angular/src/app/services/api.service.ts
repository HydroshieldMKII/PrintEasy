import { HttpClient } from '@angular/common/http';
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
        return this.http.get<RequestResponseModel>(query, { params }).pipe(
            tap(_ => console.log('fetched data')),
            catchError(this.handleError<RequestResponseModel>('getRequest'))
        );
    }

    postRequest(query: string, body: any, params?: { [key: string]: string }): Observable<RequestResponseModel> {
        return this.http.post<RequestResponseModel>(query, body, { params }).pipe(
            tap(_ => console.log('posted data')),
            catchError(this.handleError<RequestResponseModel>('postRequest'))
        );
    }

    private handleError<T>(operation = 'operation', result?: T) {
        return (error: any): Observable<T> => {
            console.error(error);
            return of(result as T);
        };
    }
}