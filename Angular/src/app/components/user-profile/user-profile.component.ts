import { Component, inject, Renderer2 } from '@angular/core';

import { ImportsModule } from '../../../imports';

import { AuthService } from '../../services/authentication.service';
import { SubmissionService } from '../../services/submission.service';
import { UserContestSubmissionsModel } from '../../models/user-contest-submissions.model';
import { ReviewModel } from '../../models/review.model';
import { ReviewService } from '../../services/review.service';
import { SubmissionModel } from '../../models/submission.model';
import { LikeService } from '../../services/like.service';
import { LikeModel } from '../../models/like.model';

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
  readonly likeService = inject(LikeService);

  userContestSubmissions: UserContestSubmissionsModel[] = [];
  responsiveOptions: any[] | undefined;
  userReviews: ReviewModel[] = [];
  userLikes: SubmissionModel[] = [];
  averageRating: number = 0;
  tab : string = 'contest-submissions';

  constructor(private renderer: Renderer2) {
    this.submissionService.getUserContestSubmissions().subscribe(submissions => {
      this.userContestSubmissions = submissions;
    });

    this.likeService.getLikes().subscribe(response => {
      this.userLikes = response;
      console.log("Likes", this.userLikes);
    });

    this.responsiveOptions = [
      {
        breakpoint: '575px',
        numVisible: 1,
        numScroll: 1
      }
    ];

    this.reviewService.getUserReviews().subscribe(response => {
      this.userReviews = response.data.reviews
      console.log(this.userReviews)
      this.averageRating = this.userReviews.reduce((acc, review) => acc + review.rating, 0) / this.userReviews.length;
    });
  }

  onLike(submission: SubmissionModel) {
    if (submission.liked) {
        const like = submission.likes.find(like => like.userId === this.authService.currentUser?.id);      
        this.likeService.deleteLike(like?.id).subscribe((response) => {
            // Supprimer la submission du tableau `userLikes`
            this.userLikes = this.userLikes.filter(like => like.id !== submission.id);    
        });
    } 
}

  prints = 3;
  joinDate = '2022-05-11';
}
