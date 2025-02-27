import { Component, inject, Renderer2 } from '@angular/core';

import { ImportsModule } from '../../../imports';

import { AuthService } from '../../services/authentication.service';
import { SubmissionService } from '../../services/submission.service';
import { UserContestSubmissionsModel } from '../../models/user-contest-submissions.model';
import { ReviewModel } from '../../models/review.model';
import { ReviewService } from '../../services/review.service';

@Component({
  selector: 'app-user-profile',
  imports: [ImportsModule],
  templateUrl: './user-profile.component.html',
  styleUrl: './user-profile.component.css'
})
export class UserProfileComponent {
  readonly authService = inject(AuthService);
  readonly submissionService = inject(SubmissionService);
  readonly reviewService = inject(ReviewService)

  userContestSubmissions: UserContestSubmissionsModel[] = [];
  userReviews: ReviewModel[] = [];
  averageRating: number = 0;
  tab : string = 'contest-submissions';

  constructor(private renderer: Renderer2) {
    this.submissionService.getUserContestSubmissions().subscribe(submissions => {
      this.userContestSubmissions = submissions;
    });

    this.reviewService.getUserReviews().subscribe(response => {
      this.userReviews = response.data.reviews
      console.log(this.userReviews)
      this.averageRating = this.userReviews.reduce((acc, review) => acc + review.rating, 0) / this.userReviews.length;
    });
  }
  prints = 3;
  joinDate = '2022-05-11';
}
