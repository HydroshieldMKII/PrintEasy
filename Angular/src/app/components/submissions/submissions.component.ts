import { Component, inject } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';

import { ImportsModule } from '../../../imports';

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
  imports: [ImportsModule, ReactiveFormsModule, StlModelViewerModule],
  templateUrl: './submissions.component.html',
  styleUrl: './submissions.component.css'
})
export class SubmissionsComponent {
  submissionService: SubmissionService = inject(SubmissionService);
  contestService: ContestService = inject(ContestService);
  authService: AuthService = inject(AuthService);

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
  submissionId: number = 0;

  constructor(private route: ActivatedRoute, private router: Router, private fb: FormBuilder) {
    this.submissionForm = this.fb.group({
      name: ['', [Validators.required, Validators.minLength(3), Validators.maxLength(30)]],
      description: ['', [Validators.maxLength(200)]],
      image: [null, this.imageValidator.bind(this)],
      stl: [null, this.stlValidator.bind(this)]
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
        breakpoint: '450px',
        numVisible: 1,
        numScroll: 1
      }
    ];
  }

  async onSubmit() {
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

  async createFileFromUrl(url: string, filename: string): Promise<File> {
    const response = await fetch(url);
    const blob = await response.blob();
    console.log('Blob:', blob);
    const fileType = blob.type || 'image/jpeg'; // Détermine le type MIME

    return new File([blob], filename, { type: fileType });
  }

  showDialog(submission: SubmissionModel | null) {
    this.isEdit = !!submission;

    this.submissionId = submission?.id || 0;

    this.submissionForm.patchValue({
      name: submission?.name || '',
      description: submission?.description || '',
      image: null,
      stl: null
    });

    this.stlUrl = submission?.stlUrl || '';
    this.imageUrl = submission?.imageUrl || '';

    this.noImagePreview = this.isEdit ? '' : 'image-preview-container';
    this.noStlPreview = this.isEdit ? '' : 'image-preview-container';

    this.display = true;
  }
}