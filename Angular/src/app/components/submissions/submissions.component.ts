import { Component, inject } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';

import { ImportsModule } from '../../../imports';

import { FormBuilder, FormGroup, Validators, ReactiveFormsModule, ValidationErrors, AbstractControl } from '@angular/forms';
import { StlModelViewerModule } from 'angular-stl-model-viewer';


import { SubmissionService } from '../../services/submission.service';
import { SubmissionModel } from '../../models/submission.model';
import { ContestService } from '../../services/contest.service';
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

  submissionForm: FormGroup;
  contest: ContestModel | null = null;
  submissions: UserSubmission[] = [];
  responsiveOptions: any[] | undefined;
  contestDurationInDays: string = '';
  paramsId: number = 0;
  display: boolean = false;
  stlUrl: string = '';
  imageUrl: string = '';
  noImagePreview: string = 'image-preview-container';
  noStlPreview: string = 'image-preview-container';
  uploadedFile: any = null;
  uploadedFileBlob: any = null;
  isEdit: boolean = false;

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

  onSubmit() {
    if (this.submissionForm.invalid) {
      return;
    }
    console.log('Form:', this.submissionForm.value);

    const submissionForm = new FormData();
    submissionForm.append('submission[name]', this.submissionForm.value.name);
    submissionForm.append('submission[description]', this.submissionForm.value.description);
    submissionForm.append('submission[contest_id]', this.paramsId.toString());
    submissionForm.append('submission[files][]', this.submissionForm.value.stl);
    submissionForm.append('submission[files][]', this.submissionForm.value.image);

    this.submissionService.createSubmission(submissionForm).subscribe((data) => {
      this.display = false;
      this.submissionService.getSubmissions(this.paramsId).subscribe((data) => {
        this.submissions = data;
      });
    });
  }

  onSelectImage(event: any) {
    console.log('Image:', event.files[0]);
    const file = event.files[0];
    this.imageUrl = URL.createObjectURL(file);
    console.log('Image URL:', this.imageUrl);
    this.noImagePreview = '';
    this.submissionForm.patchValue({ image: file });
  }

  onUploadStl(event: any) {
    console.log('File uploaded:', event);
    const file = event.files[0];
    this.uploadedFile = file;

    const reader = new FileReader();
    reader.onloadend = () => {
      this.uploadedFileBlob = reader.result;
      console.log('File:', this.uploadedFileBlob);
    };
    reader.readAsArrayBuffer(file);
    this.noStlPreview = '';
    this.submissionForm.patchValue({ stl: file });
  }

  imageValidator(control: AbstractControl): ValidationErrors | null {
    const image = control.value;
    if (!image) {
      return { imageError: 'Image is required' };
    }
    return null;
  }

  stlValidator(control: AbstractControl): ValidationErrors | null {
    const stl = control.value;
    if (!stl) {
      return { stlError: 'STL file is required' };
    }
    return null;
  }

  showDialog() {
    this.display = true;
  }
}