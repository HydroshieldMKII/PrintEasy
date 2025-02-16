import { Component } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';

import { InputTextModule } from 'primeng/inputtext';
import { InputNumberModule } from 'primeng/inputnumber';
import { DatePickerModule } from 'primeng/datepicker';
import { CalendarModule } from 'primeng/calendar';
import { FileUploadModule } from 'primeng/fileupload';
import { ButtonModule } from 'primeng/button';
import { CardModule } from 'primeng/card';
import { TextareaModule } from 'primeng/textarea';
import { FloatLabelModule } from 'primeng/floatlabel';

@Component({
  selector: 'app-contest-form',
  imports: [InputTextModule, InputNumberModule, DatePickerModule, FileUploadModule, ButtonModule, ReactiveFormsModule, BrowserModule, CardModule, TextareaModule, CalendarModule, FloatLabelModule],
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
