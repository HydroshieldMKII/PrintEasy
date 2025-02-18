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

    filter(filterParams: string, sortCategory: string, orderParams: string, searchParams: string, type: string): Observable<RequestModel[]> {
        const params: any = {};

        if (filterParams) params.filter = filterParams;
        if (sortCategory) params.sortCategory = sortCategory;
        if (orderParams) params.sort = orderParams;
        if (searchParams) params.search = searchParams;
        if (type) params.type = type;

        console.log("Filter params: ", params);
        return this.fetchRequests(params);
    }


    getPrinters(): Observable<any> {
        return this.api.getRequest('api/printer_user').pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    console.log("Printer user response: ", response.data);
                    return response.data;
                }
                return false;
            })
        );
    }

    getRequestById(id: number): Observable<RequestModel | null> {
        console.log("fetching info for request ID: ", id);
        return this.api.getRequest(`api/request/${id}`).pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    console.log("Request response: ", response.data);
                    const request = response.data?.['request'];
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
                }
                return null;
            })
        );
    }

    fetchRequests(params: any): Observable<RequestModel[]> {
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