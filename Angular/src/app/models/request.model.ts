import { PresetModel } from './preset.model';
import { UserModel } from './user.model';

export class RequestModel {
    id: number;
    name: string;
    budget: number;
    targetDate: Date;
    comment: string;
    stlFileUrls: string[];
    presets: PresetModel[];
    user: UserModel;

    constructor(
        id: number,
        name: string,
        budget: number,
        targetDate: Date,
        comment: string,
        stlFileUrls: string[],
        presets: PresetModel[],
        user: UserModel
    ) {
        this.id = id;
        this.name = name;
        this.budget = budget;
        this.targetDate = targetDate;
        this.comment = comment;
        this.stlFileUrls = stlFileUrls;
        this.presets = presets;
        this.user = user;
    }
}
