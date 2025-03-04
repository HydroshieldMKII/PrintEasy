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

    static fromAPI(data: OrderApi): OrderModel {
        return new OrderModel(
            data.id,
            (data.order_status ? data.order_status.map((order_status: OrderStatusApi) => OrderStatusModel.fromAPI(order_status)) : []),
            OfferModel.fromAPI(data.offer),
            data.available_status,
            data.review ? ReviewModel.fromAPI(data.review) : null
        );
    }
}