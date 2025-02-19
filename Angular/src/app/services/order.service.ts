import { inject, Injectable } from '@angular/core';
import { OrderModel } from '../models/order.model';

import { ApiRequestService } from './api.service';
import { ApiResponseModel } from '../models/api-response.model';

import { map } from 'rxjs/operators';
import { Observable } from 'rxjs';

@Injectable({
    providedIn: 'root'
})
export class OrderService {
    constructor(private api: ApiRequestService) { }

    getOrders(): Observable<ApiResponseModel> {
        return this.api.getRequest('api/order').pipe(
            map((response: ApiResponseModel) => {
                return response;
            })
        );
    }

    getOrder(id: number): Observable<ApiResponseModel> {
        return this.api.getRequest(`api/order/${id}`).pipe(
            map((response: ApiResponseModel) => {
                return response;
            })
        );
    }
}