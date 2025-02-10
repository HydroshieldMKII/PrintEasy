import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable, of } from 'rxjs';
import { map, catchError, tap } from 'rxjs/operators';
import { RequestResponseModel } from '../models/request-response.model';

@Injectable({
    providedIn: 'root'
})

export class ApiRequestService {
    baseUrl = 'http://localhost:3000';
    constructor(private http: HttpClient) { }

    getRequest(query: string, params?: { [key: string]: string }): Observable<RequestResponseModel> {
        return this.http.get<RequestResponseModel>(`${this.baseUrl}/${query}`, { params }).pipe(
            map(response => new RequestResponseModel({ status: response.status, errors: response.errors }, response.data))
        );
    }

    postRequest(query: string, params?: { [key: string]: string }, body?: any): Observable<RequestResponseModel> {
        return this.http.post<RequestResponseModel>(`${this.baseUrl}/${query}`, body, { params }).pipe(
            map(response => new RequestResponseModel({ status: response.status, errors: response.errors }, response.data))
        );
    }
}