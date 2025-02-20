import { OrderStatusModel } from "./order-status.model";
import { OfferModel } from "./offer.model";

export class OrderModel {
    id: number;
    order_status: OrderStatusModel[];
    offer: OfferModel;
    available_status: string[];

    constructor(
        id: number,
        order_status: OrderStatusModel[],
        offer: OfferModel,
        available_status: string[]
    ) {
        this.id = id;
        this.order_status = order_status;
        this.offer = offer;
        this.available_status = available_status;
    }
}