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
    requests: RequestModel[] = [];

    constructor(private api: ApiRequestService) { }

    getAllRequests() {
        return this.api.getRequest('api/request').pipe(
            map(response => {
                if (response.status === 200) {
                    console.log('Requests data from getall service:', response.data);
                    this.requests = (response.data as any[]).map(request => {
                        return new RequestModel(
                            request.id,
                            request.name,
                            request.budget,
                            new Date(request.target_date),
                            request.comment,
                            request.stl_file_url,
                            request.preset_requests.map((preset: any) => {
                                return new PresetModel(
                                    preset.id,
                                    preset.filament.name,
                                    preset.color.name,
                                    preset.filament.size
                                );
                            })
                        );
                    });
                }
                return this.requests;
            })
        );
    }

    getMyRequests() {
        // return this.getAllRequests().filter(r => r.id === 1);
    }
}