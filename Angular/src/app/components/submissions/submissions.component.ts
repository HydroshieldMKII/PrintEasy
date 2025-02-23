import { Component, inject } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';

import { ImportsModule } from '../../../imports';

import { SubmissionService } from '../../services/submission.service';
import { SubmissionModel } from '../../models/submission.model';
import { ContestService } from '../../services/contest.service';
import { ContestModel } from '../../models/contest.model';
import { UserSubmission } from '../../models/user-submission';

@Component({
  selector: 'app-submissions',
  imports: [ImportsModule],
  templateUrl: './submissions.component.html',
  styleUrl: './submissions.component.css'
})
export class SubmissionsComponent {
  submissionService: SubmissionService = inject(SubmissionService);
  contestService: ContestService = inject(ContestService);

  contest: ContestModel | null = null;
  submissions:  UserSubmission[] = [];
  responsiveOptions: any[] | undefined;
  contestDurationInDays: string = '';
  paramsId: number = 0;

  constructor(private route: ActivatedRoute) {
    this.route.params.subscribe(params => {
      this.paramsId = params['id'];
      console.log('Params ID:', this.paramsId);
    });

    this.contestService.getContest(this.paramsId).subscribe((data) => {
      this.contest = data;
      if (this.contest?.endAt && this.contest?.startAt) {
        const diff = new Date(this.contest?.endAt).getTime() - new Date(this.contest?.startAt).getTime();
        this.contestDurationInDays = (diff / (1000 * 60 * 60 * 24)).toFixed(0);
      }
    });

    this.submissionService.getSubmissions(this.paramsId).subscribe((data) => {
      this.submissions = data;
      console.log('Submissions:', this.submissions);
    });

    this.responsiveOptions = [
      {
        breakpoint: '1400px',
        numVisible: 2,
        numScroll: 1,
      },
      {
        breakpoint: '1199px',
        numVisible: 3,
        numScroll: 1,
      },
      {
        breakpoint: '767px',
        numVisible: 2,
        numScroll: 1,
      },
      {
        breakpoint: '575px',
        numVisible: 1,
        numScroll: 1,
      },
    ];
  }
}