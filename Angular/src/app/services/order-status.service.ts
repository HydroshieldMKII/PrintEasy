import { Injectable, inject } from "@angular/core";
import { Observable } from "rxjs";
import { map } from 'rxjs/operators';

import { ApiResponseModel } from "../models/api-response.model";
import { OrderStatusModel } from "../models/order-status.model";
import { ApiRequestService } from "./api.service";

@Injectable({
    providedIn: 'root'
})
export class OrderStatusService {
    constructor(private api: ApiRequestService) { }

    getOrderStatus(orderStatusId: number): Observable<ApiResponseModel> {
        return this.api.getRequest(`api/order_status/${orderStatusId}`).pipe(
            map((response : ApiResponseModel) => {
                response.data.order_status = OrderStatusModel.fromAPI(response.data.order_status);
                return response;
            })
        );
    }

    createOrderStatus(orderStatus: FormData): Observable<ApiResponseModel> {
        return this.api.postRequest('api/order_status', {}, orderStatus).pipe(
            map(response => {
                return response;
            })
        );
    }

    updateOrderStatus(id: number, orderStatus: FormData): Observable<ApiResponseModel> {
        return this.api.patchRequest(`api/order_status/${id}`, {}, orderStatus).pipe(
            map(response => {
                return response;
            })
        );
    }

    deleteOrderStatus(id: number): Observable<ApiResponseModel> {
        return this.api.deleteRequest(`api/order_status/${id}`).pipe(
            map(response => {
                return response;
            })
        );
    }
}
