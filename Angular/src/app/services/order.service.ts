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

    getOrders(params : { [key: string]: string } | undefined): Observable<ApiResponseModel> {
        return this.api.getRequest('api/order', params).pipe(
            map((response: ApiResponseModel) => {
                response.data.orders = response.data.orders.map((order: any) => OrderModel.fromAPI(order));
                return response;
            })
        );
    }

    getOrder(id: number): Observable<ApiResponseModel> {
        return this.api.getRequest(`api/order/${id}`).pipe(
            map((response: ApiResponseModel) => {
                response.data.order = OrderModel.fromAPI(response.data.order);
                return response;
            })
        );
    }

    createOrder(id: number): Observable<ApiResponseModel> {
        return this.api.postRequest('api/order', {}, { id: id }).pipe(
            map((response: ApiResponseModel) => {
                console.log("Create order response", response);
                // response.data.order = OrderModel.fromAPI(response.data.order);
                return response;
            })
        );
    }
}