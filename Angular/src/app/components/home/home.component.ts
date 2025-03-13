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
import { StlModelViewerModule } from 'angular-stl-model-viewer';
import { AuthService } from '../../services/authentication.service';
import { LikeService } from '../../services/like.service';
import { LikeModel } from '../../models/like.model';
@Component({
  selector: 'app-home',
  imports: [ImportsModule, TranslatePipe, StlModelViewerModule],
  templateUrl: './home.component.html',
  styleUrl: './home.component.css'
})
export class HomeComponent {
  readonly homeService = inject(HomeService);
  readonly authService = inject(AuthService);
  readonly likeService = inject(LikeService);
  readonly router = inject(Router);
  contests : ContestModel[] = [];
  requests : RequestModel[] = [];
  submissions : SubmissionModel[] = [];

  constructor() {
    this.homeService.getData().subscribe((response : HomeModel | ApiResponseModel) => {
      if (response instanceof HomeModel) {
        this.contests = response.contests;
        this.requests = response.requests;
        this.submissions = response.submissions;
      }
    })
  }

  GoTo(object : any) {
    if (object instanceof ContestModel) {
      this.router.navigate(['/contest/', object.id, "submissions"]);
    } else if (object instanceof RequestModel) {
      if (object.user?.id === this.authService.currentUser?.id) {
        this.router.navigate(['/requests/edit/', object.id]);
      }else {
        this.router.navigate(['/requests/view/', object.id]);
      }
    } else if (object instanceof SubmissionModel) {
      this.router.navigate(['/contest/', object.contest_id, "submissions"]);
    }
  }

  onLike(submission: SubmissionModel) {
    if (submission.liked) {
      const like = submission.likes.find(like => like.userId === this.authService.currentUser?.id);
      this.likeService.deleteLike(like?.id).subscribe((response) => {
        const deletedLike = LikeModel.fromApi(response.data.like);
        submission.likes = submission.likes.filter(l => l.id !== deletedLike.id);
        submission.liked = false;
      });
    } else {
      this.likeService.createLike(submission.id).subscribe((response) => {
        const newLike = LikeModel.fromApi(response.data.like);
        submission.likes.push(newLike);
        submission.liked = true;
      });
    }
  }
}
