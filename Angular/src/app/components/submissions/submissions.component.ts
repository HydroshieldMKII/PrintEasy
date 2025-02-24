import { Component, inject } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';

import { ImportsModule } from '../../../imports';

import { FormBuilder, FormGroup, Validators, ReactiveFormsModule, ValidationErrors, AbstractControl } from '@angular/forms';

import { SubmissionService } from '../../services/submission.service';
import { SubmissionModel } from '../../models/submission.model';
import { ContestService } from '../../services/contest.service';
import { ContestModel } from '../../models/contest.model';
import { UserSubmission } from '../../models/user-submission';

@Component({
  selector: 'app-submissions',
  imports: [ImportsModule, RouterLink],
  templateUrl: './submissions.component.html',
  styleUrl: './submissions.component.css'
})
export class SubmissionsComponent {
  submissionService: SubmissionService = inject(SubmissionService);
  contestService: ContestService = inject(ContestService);

  submissionForm: FormGroup;
  contest: ContestModel | null = null;
  submissions:  UserSubmission[] = [];
  responsiveOptions: any[] | undefined;
  contestDurationInDays: string = '';
  paramsId: number = 0;
  display: boolean = false;

  constructor(private route: ActivatedRoute, private fb: FormBuilder) {
    this.submissionForm = this.fb.group({
      name: ['', [Validators.required, Validators.minLength(3), Validators.maxLength(30)]],
      description: ['', [Validators.maxLength(200)]],
      // image: [null, this.imageValidator.bind(this)],
      // stl: [null, this.stlValidator.bind(this)]
    });

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

  showDialog() {
    this.display = true;
  }
}