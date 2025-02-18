import { inject, Injectable } from '@angular/core';
import { RequestModel } from '../models/request.model';
import { PresetModel } from '../models/preset.model';
import { UserModel } from '../models/user.model';

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

    filter(filterParams: string, orderParams: string): Observable<RequestModel[]> {
        return this.fetchRequest({ 'filter': filterParams, order: orderParams });
    }

    getPrinters(): Observable<boolean> {
        return this.api.getRequest('api/printer_user').pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    console.log("Printer user response: ", response.data);
                    return response.data.length > 0;
                }
                return false;
            })
        );
    }

    getAllRequests(): Observable<RequestModel[]> {
        return this.fetchRequest({'type': 'all'});
    }

    getMyRequests(): Observable<RequestModel[]> {
        return this.fetchRequest({'type': 'my'});
    }

    fetchRequest(params: any): Observable<RequestModel[]> {
        return this.api.getRequest('api/request', params).pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    this.requests = (response.data as any)?.['requests'].map((request: any) => {
                        const user = new UserModel(
                            request?.['user']?.['id'],
                            request?.['user']?.['username'],
                            request?.['user']?.['country']?.['name']
                        );

                        const presets = (request?.['preset_requests'] as any[]).map((preset: any) => {
                            return new PresetModel(
                                preset?.['print_quality'],
                                preset?.['color']?.['name'],
                                preset?.['filament']?.['name'],
                                preset?.['printer']?.['model']
                            );
                        });

                        return new RequestModel(
                            request?.['id'],
                            request?.['name'],
                            request?.['budget'],
                            new Date(request?.['target_date']),
                            request?.['comment'],
                            request?.['stl_file_url'],
                            presets,
                            user
                        );
                    });
                }
                return this.requests;
            })
        );
    }
}