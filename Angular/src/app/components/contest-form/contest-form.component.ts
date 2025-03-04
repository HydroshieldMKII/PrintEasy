import { Component } from '@angular/core';
import { inject } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule, ValidationErrors, AbstractControl } from '@angular/forms';
import { TranslatePipe, TranslateService } from '@ngx-translate/core';

import { ImportsModule } from '../../../imports';
import { ContestModel } from '../../models/contest.model';
import { ContestService } from '../../services/contest.service';

@Component({
  selector: 'app-contest-form',
  imports: [ReactiveFormsModule, ImportsModule, TranslatePipe],
  templateUrl: './contest-form.component.html',
  styleUrl: './contest-form.component.css'
})
export class ContestFormComponent {
  contestService: ContestService = inject(ContestService);
  router: Router = inject(Router);
  translate: TranslateService = inject(TranslateService);

  contestForm: FormGroup;
  isEdit: boolean = false;
  deleteDialogVisible: boolean = false;
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

      if (this.isEdit) {
        this.contestService.getContest(id).subscribe(contest => {
          if (contest instanceof ContestModel) {
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

    if (!startDate) {
      return null;
    }

    const startDateTime = new Date(startDate).getTime();
    const endDateTime = endDate ? new Date(endDate).getTime() : null;

    if (startDateTime === this.currentStartDate.getTime() && endDateTime === this.currentEndDate?.getTime() || startDateTime === this.currentStartDate.getTime() && !endDate) {
      return null;
    }

    if (endDateTime && startDateTime > endDateTime) {
      return { dateError: this.translate.instant('contest_form.error_date_start_before_end') };
    }

    if (endDateTime && startDateTime + 24 * 60 * 60 * 1000 > endDateTime) {
      this.startDatePicker = "ng-invalid ng-dirty";
      return { dateError: this.translate.instant('contest_form.error_date_24h_difference') };
    }

    if (startDateTime < new Date().getTime()) {
      this.startDatePicker = "ng-invalid ng-dirty";
      return { dateError: this.translate.instant('contest_form.error_date_after_today') };
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
      contestFormData.append('contest[description]', this.contestForm.value.description || '');
      contestFormData.append('contest[submission_limit]', this.contestForm.value.limit);
      contestFormData.append('contest[start_at]', this.contestForm.value.startDate);
      contestFormData.append('contest[end_at]', this.contestForm.value.endDate);
      console.log('ContestFormData:', contestFormData);
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

  onDelete() {
    this.deleteDialogVisible = true;
  }

  confirmDelete() {
    this.contestService.deleteContest(this.route.snapshot.params['id']).subscribe(response => {
      if (response.status === 200) {
        this.router.navigate(['/contest']);
      }
    });
  }

  onCancel() {
    this.contestForm.reset();
    this.imageUrl = '';
    this.noImagePreview = "image-preview-container";
    this.currentEndDate = null;
    this.currentStartDate = new Date();
  }
}