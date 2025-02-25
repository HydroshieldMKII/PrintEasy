export class OfferModel {
    requestId: number;
    requestName: string;
    requestBudget: number;
    requestComment: string;
    requestTargetdate: Date;
    offers: any[];

    constructor(
        id: number,
        name: string,
        budget: number,
        comment: string,
        target_date: Date,
        offers: any[] = []
    ) {
        this.requestId = id;
        this.requestName = name;
        this.requestBudget = budget;
        this.requestComment = comment;
        this.requestTargetdate = target_date;
        this.offers = offers;
    }
}
