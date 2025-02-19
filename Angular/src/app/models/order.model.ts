import { OrderStatusModel } from "./order-status.model";
import { OfferModel } from "./offer.model";

export class OrderModel {
    id: number;
    orderStatus: OrderStatusModel[];
    offer: OfferModel;
    available_status: string[];

    constructor(
        id: number,
        orderStatus: OrderStatusModel[],
        offer: OfferModel,
        available_status: string[]
    ) {
        this.id = id;
        this.orderStatus = orderStatus;
        this.offer = offer;
        this.available_status = available_status;
    }
}