import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

import { ApiResponseModel } from '../models/api-response.model';
import { ApiRequestService } from './api.service';
import { PrinterUserModel } from '../models/printer-user.model';
import { PrinterUserApi } from '../models/printer-user.model';

import { MessageService } from 'primeng/api';
import { TranslateService } from '@ngx-translate/core';
import { FormGroup } from '@angular/forms';

@Injectable({
  providedIn: 'root'
})
export class PrinterUserService {
  messageService: MessageService = inject(MessageService);
  translateService: TranslateService = inject(TranslateService);

  constructor(private api: ApiRequestService) { }

  getPrinterUsers(): Observable<PrinterUserModel[]> {
    return this.api.getRequest('api/printer_user').pipe(
      map(response => {
        if (response.status === 200) {
          return response.data.printer_users.map((data: PrinterUserApi) => PrinterUserModel.fromAPI(data));
        } else {
          return [];
        }
      })
    );
  }

  createPrinterUser(printerForm: FormGroup): Observable<ApiResponseModel> {
    return this.api.postRequest('api/printer_user', {}, PrinterUserModel.toAPI(printerForm)).pipe(
      map(response => {
        return response;
      })
    );
  }

  updatePrinterUser(printerForm: FormGroup, id: number): Observable<ApiResponseModel> {
    return this.api.putRequest(`api/printer_user/${id}`, {}, PrinterUserModel.toAPI(printerForm)).pipe(
      map(response => {
        return response;
      })
    );
  }

  deletePrinterUser(id: number): Observable<ApiResponseModel> {
    return this.api.deleteRequest(`api/printer_user/${id}`).pipe(
      map(response => {
        return response;
      })
    );
  }
}
