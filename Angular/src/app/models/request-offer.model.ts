import { OfferApi, OfferModel } from "./offer.model";

export type RequestOfferApi = {
    id: number;
    name: string;
    budget: number;
    comment: string;
    target_date: string;
    offers: OfferApi[];
}

export class RequestOfferModel {
    id: number;
    name: string;
    budget: number;
    comment: string;
    targetDate: Date;
    offers: OfferModel[];

    constructor(
        id: number,
        name: string,
        budget: number,
        comment: string,
        targetDate: Date,
        offers: OfferModel[]
    ) {
        this.id = id;
        this.name = name;
        this.budget = budget;
        this.comment = comment;
        this.targetDate = targetDate;
        this.offers = offers;
    }

    static fromAPI(data: RequestOfferApi): RequestOfferModel {
        return new RequestOfferModel(
            data.id,
            data.name,
            data.budget,
            data.comment,
            new Date(data.target_date + 'T00:00:00'),
            data.offers.map((offer: OfferApi) => OfferModel.fromAPI(offer))
        );
    }
}