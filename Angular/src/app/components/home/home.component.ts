import { Component, inject } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { MessageService } from 'primeng/api';
import { ImportsModule } from '../../../imports';
import { TranslatePipe, TranslateService } from '@ngx-translate/core';
import { Router, RouterLink } from '@angular/router';
import { HomeApi, HomeModel, HomeService } from '../../services/home.service';
import { ApiRequestService } from '../../services/api.service';
import { ApiResponseModel } from '../../models/api-response.model';
import { ContestModel } from '../../models/contest.model';
import { RequestModel } from '../../models/request.model';
import { SubmissionModel } from '../../models/submission.model';

@Component({
  selector: 'app-home',
  imports: [ImportsModule, TranslatePipe],
  templateUrl: './home.component.html',
  styleUrl: './home.component.css'
})
export class HomeComponent {
  readonly homeService = inject(HomeService);
  contests : ContestModel[] = [];
  requests : RequestModel[] = [];
  submissions : SubmissionModel[] = [];

  constructor() {
    this.homeService.getData().subscribe((response : HomeModel | ApiResponseModel) => {
      console.log("Home data: ", response);
      if (response instanceof HomeModel) {
        this.contests = response.contests;
        this.requests = response.requests;
        this.submissions = response.submissions;
      }
    })
  }
}
