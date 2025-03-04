import { OrderStatusModel } from "./order-status.model";
import { OfferModel } from "./offer.model";
import { ReviewModel } from "./review.model";

export class OrderModel {
    id: number;
    orderStatus: OrderStatusModel[];
    offer: OfferModel | null;
    availableStatus: string[];
    review: ReviewModel | null;

    constructor(
        id: number,
        orderStatus: OrderStatusModel[],
        offer: OfferModel | null,
        availableStatus: string[],
        review: ReviewModel | null
    ) {
        this.id = id;
        this.orderStatus = orderStatus;
        this.offer = offer;
        this.availableStatus = availableStatus;
        this.review = review;
    }

    static fromAPI(any: any): OrderModel | null {
        if (!any) {
            return null;
        }
        return new OrderModel(
            any.id,
            (any.order_status ? any.order_status.map((order_status: any) => OrderStatusModel.fromAPI(order_status)) : []),
            OfferModel.fromAPI(any.offer),
            any.available_status,
            ReviewModel.fromAPI(any.review)
        );
    }
}