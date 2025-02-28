import { Component, inject, Renderer2 } from '@angular/core';
import { CommonModule } from '@angular/common';

import { RatingModule } from 'primeng/rating';
import { ImportsModule } from '../../../imports';
import { TabViewModule } from 'primeng/tabview';

import { AuthService } from '../../services/authentication.service';
import { SubmissionService } from '../../services/submission.service';
import { UserContestSubmissionsModel } from '../../models/user-contest-submissions.model';

@Component({
  selector: 'app-user-profile',
  imports: [RatingModule, TabViewModule, CommonModule, ImportsModule],
  templateUrl: './user-profile.component.html',
  styleUrl: './user-profile.component.css'
})
export class UserProfileComponent {
  readonly authService = inject(AuthService);
  readonly submissionService = inject(SubmissionService);

  userContestSubmissions: UserContestSubmissionsModel[] = [];
  responsiveOptions: any[] | undefined;

  constructor(private renderer: Renderer2) {
    this.submissionService.getUserContestSubmissions().subscribe(submissions => {
      this.userContestSubmissions = submissions;
    });

    this.responsiveOptions = [
      {
        breakpoint: '575px',
        numVisible: 1,
        numScroll: 1
      }
    ];
  }

  rating = 0;
  reviews = 0;
  prints = 3;
  joinDate = '2022-05-11';
}
