import { inject, Injectable } from '@angular/core';
import { OrderApi, OrderModel } from '../models/order.model';

import { ApiRequestService } from './api.service';
import { ApiResponseModel } from '../models/api-response.model';

import { map } from 'rxjs/operators';
import { Observable } from 'rxjs';

@Injectable({
    providedIn: 'root'
})
export class OrderService {
    constructor(private api: ApiRequestService) { }

    getOrders(params : { [key: string]: string } | undefined): Observable<OrderModel[] | ApiResponseModel> {
        return this.api.getRequest('api/order', params).pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    return response.data.orders.map((order: OrderApi) => OrderModel.fromAPI(order));
                }
                return response;
            })
        );
    }

    getOrder(id: number): Observable<OrderModel | ApiResponseModel> {
        return this.api.getRequest(`api/order/${id}`).pipe(
            map((response: ApiResponseModel) => {
                console.log("Get order response", response);
                if (response.status === 200) {
                    return OrderModel.fromAPI(response.data.order);
                }
                return response;
            })
        );
    }

    createOrder(id: number): Observable<OrderModel | ApiResponseModel> {
        return this.api.postRequest('api/order', {}, { id: id }).pipe(
            map((response: ApiResponseModel) => {
                console.log("Create order response", response);
                if (response.status === 201) {
                    return OrderModel.fromAPI(response.data.order);
                }
                return response;
            })
        );
    }

    getReport(params : {[key: string]: string}): Observable<ApiResponseModel> {
        return this.api.getRequest('api/order/report', params);
    }
}