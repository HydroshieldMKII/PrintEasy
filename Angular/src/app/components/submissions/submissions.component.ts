import { Component, inject, ViewEncapsulation, Renderer2 } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { TranslateParser, TranslatePipe, TranslateService } from '@ngx-translate/core';
import { RouterLink } from '@angular/router';

import { ImportsModule } from '../../../imports';
import { MessageService } from 'primeng/api';

import { FormBuilder, FormGroup, Validators, ReactiveFormsModule, ValidationErrors, AbstractControl } from '@angular/forms';
import { StlModelViewerModule } from 'angular-stl-model-viewer';

import { SubmissionService } from '../../services/submission.service';
import { ContestService } from '../../services/contest.service';
import { AuthService } from '../../services/authentication.service';
import { LikeService } from '../../services/like.service';
import { SubmissionModel } from '../../models/submission.model';
import { ContestModel } from '../../models/contest.model';
import { UserSubmission } from '../../models/user-submission';
import { LikeModel } from '../../models/like.model';

@Component({
  selector: 'app-submissions',
  imports: [ImportsModule, ReactiveFormsModule, StlModelViewerModule, TranslatePipe, RouterLink],
  templateUrl: './submissions.component.html',
  styleUrl: './submissions.component.css'
})
export class SubmissionsComponent {
  submissionService: SubmissionService = inject(SubmissionService);
  contestService: ContestService = inject(ContestService);
  authService: AuthService = inject(AuthService);
  messageService: MessageService = inject(MessageService);
  translateService: TranslateService = inject(TranslateService);
  likeService: LikeService = inject(LikeService);

  submissionForm: FormGroup;
  contest: ContestModel | null = null;
  submissions: UserSubmission[] = [];
  contestDurationInDays: string = '';
  paramsId: number = 0;
  display: boolean = false;
  deleteDialogVisible: boolean = false
  stlUrl: string = '';
  imageUrl: string = '';
  noImagePreview: string = 'image-preview-container';
  noStlPreview: string = 'image-preview-container';
  uploadedFile: any = null;
  uploadedFileBlob: any = null;
  isEdit: boolean = false;
  finished: boolean = false;
  winner_username: string = '';
  submissionId: number = 0;

  constructor(private route: ActivatedRoute, private router: Router, private fb: FormBuilder, private renderer: Renderer2) {
    this.submissionForm = this.fb.group({
      name: ['', [Validators.required, Validators.minLength(3), Validators.maxLength(30)]],
      description: ['', [Validators.maxLength(200)]],
      image: [null, this.imageValidator.bind(this)],
      stl: [null, this.stlValidator.bind(this)]
    });

    this.route.params.subscribe(params => {
      this.paramsId = params['id'];
    });

    this.contestService.getContest(this.paramsId).subscribe((data) => {
      if (data instanceof ContestModel) {
        this.contest = data;
        if (this.contest?.endAt && this.contest?.startAt) {
          const diff = new Date(this.contest?.endAt).getTime() - new Date().getTime();
          this.contestDurationInDays = (diff / (1000 * 60 * 60 * 24)).toFixed(0);
        }
      }
    });

    this.submissionService.getSubmissions(this.paramsId).subscribe((data) => {
      this.submissions = data;
    });
  }

  ngOnInit() {
    const bootstrapLink = document.querySelector('link[href*="bootstrap"]');
    if (bootstrapLink) {
      this.renderer.removeChild(document.head, bootstrapLink);
    }
  }

  downloadStl(downloadUrl: string): void {
    window.open(downloadUrl, '_blank');
  }

  onSubmit() {
    if (this.submissionForm.invalid) {
      return;
    }

    const submissionForm = new FormData();
    submissionForm.append('submission[name]', this.submissionForm.value.name);
    submissionForm.append('submission[description]', this.submissionForm.value.description);
    submissionForm.append('submission[contest_id]', this.paramsId.toString());

    if (this.submissionForm.value.stl) {
      submissionForm.append('submission[stl]', this.submissionForm.value.stl);
    }

    if (this.submissionForm.value.image) {
      submissionForm.append('submission[image]', this.submissionForm.value.image);
    }

    const submissionObservable = this.isEdit
      ? this.submissionService.updateSubmission(submissionForm, this.submissionId)
      : this.submissionService.createSubmission(submissionForm);

    submissionObservable.subscribe(() => {
      this.display = false;
      this.submissionService.getSubmissions(this.paramsId).subscribe((data) => {
        this.submissions = data;
      });
    });

    this.submissionForm.reset();
    this.imageUrl = '';
    this.stlUrl = '';
    this.uploadedFile = null;
    this.uploadedFileBlob = null;
    this.noImagePreview = 'image-preview-container';
    this.noStlPreview = 'image-preview-container';
  }

  onCancel() {
    this.display = false;
    this.submissionForm.reset();
    this.imageUrl = '';
    this.stlUrl = '';
    this.uploadedFile = null;
    this.uploadedFileBlob = null;
    this.noImagePreview = 'image-preview-container';
    this.noStlPreview = 'image-preview-container';
  }

  onDelete(id: number) {
    const isContestFinished = this.contest?.finished;
    const isContestStarted = this.contest?.started;

    if (!isContestStarted) {
      this.messageService.add({ severity: 'error', summary: this.translateService.instant('global.error'), detail: this.translateService.instant('submissions.contest_not_started') });
      return;
    }

    if (isContestFinished) {
      this.messageService.add({ severity: 'error', summary: this.translateService.instant('global.error'), detail: this.translateService.instant('submissions.contest_ended') });
      return;
    }

    this.deleteDialogVisible = true;
    this.submissionId = id;
  }

  confirmDelete() {
    this.submissionService.deleteSubmission(this.submissionId).subscribe(() => {
      this.deleteDialogVisible = false;
      this.display = false;
      this.submissionService.getSubmissions(this.paramsId).subscribe((data) => {
        this.submissions = data;
      });
    });
  }

  onSelectImage(event: any) {
    const file = event.files[0];
    const allowedTypes = ['image/jpeg', 'image/png', 'image/jpg'];
    if (allowedTypes.includes(file.type)) {
      this.imageUrl = URL.createObjectURL(file);
      this.noImagePreview = '';
      this.submissionForm.patchValue({ image: file });
    }
  }

  onUploadStl(event: any) {
    const file = event.files[0];
    this.uploadedFile = file;

    if (file && file.name.endsWith('.stl')) {
      const reader = new FileReader();
      reader.onloadend = () => {
        this.uploadedFileBlob = reader.result;
      };
      reader.readAsArrayBuffer(file);
      this.noStlPreview = '';
      this.submissionForm.patchValue({ stl: file });
    }
  }

  onFileUploadError(event: any) {
  }

  imageValidator(control: AbstractControl): ValidationErrors | null {
    const image = control.value;
    if (!image && !this.isEdit) {
      return { imageError: 'Image is required' };
    }

    return null;
  }

  stlValidator(control: AbstractControl): ValidationErrors | null {
    const stl = control.value;

    if (!stl && !this.isEdit) {
      return { stlError: 'STL file is required' };
    }

    return null;
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

  showDialog(submission: SubmissionModel | null) {
    const userSubmissions = this.submissions.filter(sub => sub.mine);
    const hasNoSubmissions = userSubmissions.length === 0;
    const hasRemainingSlots = userSubmissions.length > 0 && userSubmissions[0].submissions.length < (this.contest?.submissionLimit ?? 0);
    const isContestFinished = this.contest?.finished;
    const isContestStarted = this.contest?.started;
    const isEditMode = !!submission;

    if (!isContestStarted) {
      this.messageService.add({ severity: 'error', summary: this.translateService.instant('global.error'), detail: this.translateService.instant('submissions.contest_not_started') });
      return;
    }

    if (isContestFinished) {
      this.messageService.add({ severity: 'error', summary: this.translateService.instant('global.error'), detail: this.translateService.instant('submissions.contest_ended') });
      return;
    }

    if (!isEditMode && !hasNoSubmissions && !hasRemainingSlots) {
      this.messageService.add({ severity: 'error', summary: this.translateService.instant('global.error'), detail: this.translateService.instant('submissions.submission_limit_reached') });
      return;
    }

    this.isEdit = isEditMode;
    this.submissionId = submission?.id || 0;

    this.submissionForm.patchValue({
      name: submission?.name || '',
      description: submission?.description || '',
      image: null,
      stl: null
    });

    this.stlUrl = submission?.stlUrl || '';
    this.imageUrl = submission?.imageUrl || '';

    this.noImagePreview = this.isEdit ? "" : "image-preview-container";
    this.noStlPreview = this.isEdit ? "" : "image-preview-container";

    this.display = true;
  }

}