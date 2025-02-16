import { inject, Injectable } from '@angular/core';
import { RequestModel } from '../models/request.model';
import { PresetModel } from '../models/preset.model';

import { ApiRequestService } from './api.service';
import { ApiResponseModel } from '../models/api-response.model';

import { map } from 'rxjs/operators';
import { Observable } from 'rxjs';
import { MessageService } from 'primeng/api';

@Injectable({
    providedIn: 'root'
})
export class RequestService {
    messageService: MessageService = inject(MessageService);
    constructor(private api: ApiRequestService) { }

    getAllRequests() {
        return [
            new RequestModel(
                1,
                "Cool print idea",
                5,
                new Date("2021-01-01"),
                "Canada",
                "Creality 3",
                new PresetModel(1, "PLA", "Red", 1.75)
            ),
            new RequestModel(
                2,
                "Awesome gadget",
                3,
                new Date("2021-02-15"),
                "USA",
                "Ender 5",
                new PresetModel(2, "ABS", "Blue", 1.75)
            ),
            new RequestModel(
                3,
                "Useful tool",
                4,
                new Date("2021-03-10"),
                "UK",
                "Prusa i3",
                new PresetModel(3, "PETG", "Green", 1.75)
            ),
            new RequestModel(
                4,
                "Decorative item",
                2,
                new Date("2021-04-05"),
                "Germany",
                "Anycubic i3",
                new PresetModel(4, "PLA", "Yellow", 1.75)
            ),
            new RequestModel(
                5,
                "Functional prototype",
                6,
                new Date("2021-05-20"),
                "Australia",
                "FlashForge",
                new PresetModel(5, "Nylon", "Black", 1.75)
            )
        ];
    }
}