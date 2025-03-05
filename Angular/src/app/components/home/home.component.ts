import { Component, inject } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { MessageService } from 'primeng/api';
import { ImportsModule } from '../../../imports';
import { TranslatePipe, TranslateService } from '@ngx-translate/core';
import { Router, RouterLink } from '@angular/router';
import { HomeApi, HomeService } from '../../services/home.service';
import { ApiRequestService } from '../../services/api.service';
import { ApiResponseModel } from '../../models/api-response.model';

@Component({
  selector: 'app-home',
  imports: [ImportsModule, TranslatePipe],
  templateUrl: './home.component.html',
  styleUrl: './home.component.css'
})
export class HomeComponent {
  readonly homeService = inject(HomeService);

  constructor() {
    this.homeService.getData().subscribe((response : HomeApi | ApiResponseModel) => {
      console.log("Home data: ", response);
    })
  }
}
