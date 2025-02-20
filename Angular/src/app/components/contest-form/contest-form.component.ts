import { Component } from '@angular/core';
import { inject } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule, ValidationErrors, AbstractControl } from '@angular/forms';

import { ImportsModule } from '../../../imports';
import { ContestModel } from '../../models/contest.model';
import { ContestService } from '../../services/contest.service';

@Component({
  selector: 'app-contest-form',
  imports: [ReactiveFormsModule, ImportsModule],
  templateUrl: './contest-form.component.html',
  styleUrl: './contest-form.component.css'
})
export class ContestFormComponent {
  contestService: ContestService = inject(ContestService);
  router: Router = inject(Router);

  contestForm: FormGroup;
  isEdit: boolean = false;
  startDatePicker = "";
  imageUrl: string = '';
  noImagePreview: string = "image-preview-container";
  currentStartDate: Date = new Date();
  currentEndDate: Date | null = null;

  constructor(private fb: FormBuilder, private route: ActivatedRoute) {
    this.contestForm = this.fb.group({
      theme: ['', [Validators.required, Validators.minLength(3), Validators.maxLength(30)]],
      description: ['', [Validators.maxLength(200)]],
      limit: [1, [Validators.required, Validators.min(1), Validators.max(30)]],
      startDate: [null, [Validators.required]],
      endDate: [""],
      image: [null, this.imageValidator.bind(this)] // ??
    }, { validators: this.dateValidator.bind(this) }
    );

    this.route.params.subscribe(params => {
      const id = params['id'];
      this.isEdit = id ? true : false;

      console.log('IsEdit:', this.isEdit);

      if (this.isEdit) {
        this.contestService.getContest(id).subscribe(contest => {
          if (contest) {
            this.imageUrl = contest.image;
            this.noImagePreview = "";
            this.currentStartDate = new Date(contest.startAt);
            this.currentEndDate = contest.endAt ? new Date(contest.endAt) : null;

            this.contestForm.patchValue({
              theme: contest.theme,
              description: contest.description,
              limit: contest.submissionLimit,
              startDate: new Date(contest.startAt),
              endDate: contest.endAt ? new Date(contest.endAt) : null
            });
          }
        });
      }
    });
  }

  imageValidator(control: AbstractControl): ValidationErrors | null {
    const image = control.value;
    if (!image && !this.isEdit) {
      return { imageError: 'Image is required' };
    }
    return null;
  }

  dateValidator(group: AbstractControl): ValidationErrors | null {
    const startDate = group.get('startDate')?.value;
    const endDate = group.get('endDate')?.value;

    if (!startDate || !endDate) {
      return null;
    }
    
    if (startDate.getTime() === this.currentStartDate.getTime() && endDate.getTime() === this.currentEndDate?.getTime()) {
      return null;
    }

    if (startDate && new Date() > new Date(startDate)) {
      this.startDatePicker = "ng-invalid ng-dirty";
      return { dateError: 'La date de début doit être avant la date actuelle' };
    }

    if (startDate.getTime() > endDate.getTime()) {
      this.startDatePicker = "ng-invalid ng-dirty";
      return { dateError: 'La date de début doit être avant la date de fin' };
    }

    if (startDate.getTime() + 24 * 60 * 60 * 1000 > endDate.getTime()) {
      this.startDatePicker = "ng-invalid ng-dirty";
      return { dateError: 'Il doit y avoir 24h de différence' };
    } 

    this.startDatePicker = "";
    return null;
  }

  onFileSelect(event: any) {
    const file = event.files[0];
    this.imageUrl = file["objectURL"].changingThisBreaksApplicationSecurity;
    this.contestForm.patchValue({ image: file });
    this.noImagePreview = "";
  }

  onSubmit() {
    if (this.contestForm.valid) {
      console.log('Données du concours:', this.contestForm.value);

      const contestFormData = new FormData();

      contestFormData.append('contest[theme]', this.contestForm.value.theme);
      contestFormData.append('contest[description]', this.contestForm.value.description);
      contestFormData.append('contest[submission_limit]', this.contestForm.value.limit);
      contestFormData.append('contest[start_at]', this.contestForm.value.startDate);
      contestFormData.append('contest[end_at]', this.contestForm.value.endDate);

      if (this.contestForm.value.image) {
        contestFormData.append('contest[image]', this.contestForm.value.image);
      }

      const contestObservable = this.isEdit
        ? this.contestService.updateContest(this.route.snapshot.params['id'], contestFormData)
        : this.contestService.createContest(contestFormData);

      contestObservable.subscribe(response => {
        if ((this.isEdit && response.status === 200) || (!this.isEdit && response.status === 201)) {
          this.router.navigate(['/contest']);
        }
      });
    }
  }

  onCancel() {
    this.contestForm.reset();
  }
}