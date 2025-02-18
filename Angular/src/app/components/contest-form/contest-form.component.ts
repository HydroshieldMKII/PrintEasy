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
  imagePreview: boolean = false;
  startDatePicker = "";
  imageUrl: string = '';
  
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
            this.contestForm.patchValue({
              theme: contest.theme,
              description: contest.description,
              limit: contest.submissionLimit,
              startDate: new Date(contest.startAt),
              endDate: contest.endAt ? new Date(contest.endAt) : null,
              image: contest.image
            });
            this.imageUrl = contest.image;
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

    if (startDate && endDate && (new Date(startDate).getTime() + 24 * 60 * 60 * 1000) > new Date(endDate).getTime()) {
      this.startDatePicker = "ng-invalid ng-dirty";
      return { dateError: 'La date de début doit être avant la date de fin' };
    }
    this.startDatePicker = "";
    return null;
  }

  onFileSelect(event: any) {
    const file = event.files[0];
    this.imageUrl = file["objectURL"].changingThisBreaksApplicationSecurity;
    console.log('Image:', file["objectURL"].changingThisBreaksApplicationSecurity);
    this.contestForm.patchValue({ image: file });
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
      contestFormData.append('contest[image]', this.contestForm.value.image);

      this.contestService.createContest(contestFormData).subscribe(
        response => {
          if (response.status === 201) {
            this.contestForm.reset();
          }
        }
      );
    }
  }

  onCancel() {
    this.contestForm.reset();
  }
}