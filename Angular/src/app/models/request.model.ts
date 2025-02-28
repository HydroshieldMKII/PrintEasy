import { RequestPresetModel } from './request-preset.model';
import { PresetModel } from './preset.model';
import { UserModel } from './user.model';

export class RequestModel {
    id: number;
    name: string;
    budget: number;
    targetDate: Date;
    comment: string;
    stlFileUrl: string;
    presets: RequestPresetModel[];
    user: UserModel;
    hasOffers: boolean;
    hasOfferAccepted: boolean;

    constructor(
        id: number,
        name: string,
        budget: number,
        targetDate: Date,
        comment: string,
        stlFileUrl: string,
        presets: RequestPresetModel[],
        user: UserModel,
        hasOffers: boolean,
        hasOfferAccepted: boolean
    ) {
        this.id = id;
        this.name = name;
        this.budget = budget;
        this.targetDate = targetDate;
        this.comment = comment;
        this.stlFileUrl = stlFileUrl;
        this.presets = presets;
        this.user = user;
        this.hasOffers = hasOffers;
        this.hasOfferAccepted = hasOfferAccepted
    }

    static fromAPI(data: any): RequestModel {
        return new RequestModel(
            data.id,
            data.name,
            data.budget,
            new Date(data.target_date),
            data.comment,
            data.stl_file_url,
            (data.presets ? data.presets.map((preset: any) => PresetModel.fromAPI(preset)) : []),
            UserModel.fromAPI(data.user),
            data.has_offers,
            data.has_offer_accepted
        );
    }
}
