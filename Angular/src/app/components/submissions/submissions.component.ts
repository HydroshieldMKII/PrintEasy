import { Component, inject, ViewEncapsulation, Renderer2 } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { TranslateParser, TranslatePipe } from '@ngx-translate/core';

import { ImportsModule } from '../../../imports';
import { MessageService } from 'primeng/api';

import { FormBuilder, FormGroup, Validators, ReactiveFormsModule, ValidationErrors, AbstractControl } from '@angular/forms';
import { StlModelViewerModule } from 'angular-stl-model-viewer';

import { SubmissionService } from '../../services/submission.service';
import { ContestService } from '../../services/contest.service';
import { AuthService } from '../../services/authentication.service';
import { SubmissionModel } from '../../models/submission.model';
import { ContestModel } from '../../models/contest.model';
import { UserSubmission } from '../../models/user-submission';

@Component({
  selector: 'app-submissions',
  imports: [ImportsModule, ReactiveFormsModule, StlModelViewerModule, TranslatePipe],
  templateUrl: './submissions.component.html',
  styleUrl: './submissions.component.css'
})
export class SubmissionsComponent {
  submissionService: SubmissionService = inject(SubmissionService);
  contestService: ContestService = inject(ContestService);
  authService: AuthService = inject(AuthService);
  messageService: MessageService = inject(MessageService);

  submissionForm: FormGroup;
  contest: ContestModel | null = null;
  submissions: UserSubmission[] = [];
  responsiveOptions: any[] | undefined;
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
      this.contest = data;
      if (this.contest?.endAt && this.contest?.startAt) {
        const diff = new Date(this.contest?.endAt).getTime() - new Date(this.contest?.startAt).getTime();
        this.contestDurationInDays = (diff / (1000 * 60 * 60 * 24)).toFixed(0);
      }
    });

    this.submissionService.getSubmissions(this.paramsId).subscribe((data) => {
      this.submissions = data;
    });

    this.responsiveOptions = [
      {
        breakpoint: '575px',
        numVisible: 1,
        numScroll: 1
      }
    ];
  }

  ngOnInit() {
    const bootstrapLink = document.querySelector('link[href*="bootstrap"]');
    if (bootstrapLink) {
      this.renderer.removeChild(document.head, bootstrapLink);
    }
  }

  onSubmit() {
    if (this.submissionForm.invalid) {
      return;
    }
    console.log('Form:', this.submissionForm.value);

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

  onDelete(id: number) {
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
    console.log('Image:', event.files[0]);
    const file = event.files[0];
    const allowedTypes = ['image/jpeg', 'image/png', 'image/jpg'];
    if (allowedTypes.includes(file.type)) {
      this.imageUrl = URL.createObjectURL(file);
      this.noImagePreview = '';
      this.submissionForm.patchValue({ image: file });
    } else {
      console.log('Invalid image type');
    }
  }

  onUploadStl(event: any) {
    console.log('File uploaded:', event);
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
    } else {
      console.log('Invalid STL file');
    }
  }

  onFileUploadError(event: any) {
    console.log('Error:', event);
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

  showDialog(submission: SubmissionModel | null) {
    const userSubmissions = this.submissions.filter(sub => sub.mine);
    const hasNoSubmissions = userSubmissions.length === 0;
    const hasRemainingSlots = userSubmissions.length > 0 && userSubmissions[0].submissions.length < (this.contest?.submissionLimit ?? 0);
    const isContestFinished = this.contest?.finished;
    const isEditMode = !!submission;
  
    if (isContestFinished) {
      this.messageService.add({ severity: 'error', summary: 'Error', detail: 'Contest is finished' });
      return;
    }
  
    if (!isEditMode && !hasNoSubmissions && !hasRemainingSlots) {
      this.messageService.add({ severity: 'error', summary: 'Error', detail: 'Submission limit reached' });
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