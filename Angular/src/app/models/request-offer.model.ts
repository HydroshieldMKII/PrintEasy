import { OfferModel } from "./offer.model";

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

    static fromAPI(data: any): RequestOfferModel | null {
        if (!data) {
            return null;
        }
        return new RequestOfferModel(
            data.id,
            data.name,
            data.budget,
            data.comment,
            new Date(data.target_date),
            data.offers.map((offer: any) => OfferModel.fromAPI(offer))
        );
    }
}