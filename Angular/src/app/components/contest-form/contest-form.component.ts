import { Component } from '@angular/core';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';

import { ImportsModule } from '../../../imports';

@Component({
  selector: 'app-contest-form',
  imports: [ReactiveFormsModule, ImportsModule],
  templateUrl: './contest-form.component.html',
  styleUrl: './contest-form.component.css'
})
export class ContestFormComponent {
  contestForm: FormGroup;

  constructor(private fb: FormBuilder) {
    this.contestForm = this.fb.group({
      theme: ['', Validators.required,  Validators.minLength(3), Validators.maxLength(30)],
      description: ['', Validators.required, Validators.maxLength(200)],
      limit: [1, [Validators.required, Validators.min(1)]],
      startDate: [null, Validators.required],
      endDate: [null, Validators.required],
      image: [null] // ??
    });
  }

  onFileSelect(event: any) {
    const file = event.files[0]; 
    this.contestForm.patchValue({ image: file });
  }

  onSubmit() {
    if (this.contestForm.valid) {
      console.log('Données du concours:', this.contestForm.value);
    }
  }

  onCancel() {
    this.contestForm.reset();
    // this.router.navigate(['/url-de-redirection']);
  }
}
