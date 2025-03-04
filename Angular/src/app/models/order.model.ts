import { OrderStatusModel, OrderStatusApi } from "./order-status.model";
import { OfferModel, OfferApi } from "./offer.model";
import { ReviewModel, ReviewApi } from "./review.model";


export type OrderApi = {
    id: number;
    order_status: OrderStatusApi[];
    offer: OfferApi;
    available_status: string[];
    review: ReviewApi | null;
}

export class OrderModel {
    id: number;
    orderStatus: OrderStatusModel[];
    offer: OfferModel;
    availableStatus: string[];
    review: ReviewModel | null;

    constructor(
        id: number,
        orderStatus: OrderStatusModel[],
        offer: OfferModel,
        availableStatus: string[],
        review: ReviewModel | null
    ) {
        this.id = id;
        this.orderStatus = orderStatus;
        this.offer = offer;
        this.availableStatus = availableStatus;
        this.review = review;
    }

    static fromAPI(any: OrderApi): OrderModel {
        return new OrderModel(
            any.id,
            (any.order_status ? any.order_status.map((order_status: OrderStatusApi) => OrderStatusModel.fromAPI(order_status)) : []),
            OfferModel.fromAPI(any.offer),
            any.available_status,
            ReviewModel.fromAPI(any.review)
        );
    }
}