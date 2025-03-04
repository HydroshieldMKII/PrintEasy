import { RequestPresetModel } from './request-preset.model';
import { PresetModel } from './preset.model';
import { UserModel } from './user.model';

export type RequestApi = {
    id: number;
    name: string;
    budget: number;
    target_date: string;
    comment: string;
    stl_file_url: string;
    preset_requests: RequestPresetModel[];
    user: any;
    has_offers: boolean;
    accepted_at: string | null;
}

export class RequestModel {
    id: number;
    name: string;
    budget: number;
    targetDate: Date;
    comment: string;
    stlFileUrl: string;
    presets: RequestPresetModel[];
    user: UserModel | null;
    hasOffers: boolean;
    acceptedAt: Date | null;

    constructor(
        id: number,
        name: string,
        budget: number,
        targetDate: Date,
        comment: string,
        stlFileUrl: string,
        presets: RequestPresetModel[],
        user: UserModel | null,
        hasOffers: boolean,
        acceptedAt: Date | null
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
        this.acceptedAt = acceptedAt;
    }

    static fromAPI(data: any): RequestModel | null {
        if (!data) {
            return null;
        }
        return new RequestModel(
            data.id,
            data.name,
            data.budget,
            new Date(data.target_date),
            data.comment,
            data.stl_file_url,
            (data?.preset_requests?.map((preset: any) => RequestPresetModel.fromAPI(preset)) ?? []),
            UserModel.fromAPI(data.user),
            data.has_offers,
            data.accepted_at ? new Date(data.accepted_at) : null
        );
    }
}
