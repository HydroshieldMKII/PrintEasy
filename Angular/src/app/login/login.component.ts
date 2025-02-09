import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { HttpClientModule } from '@angular/common/http';
import { FormsModule } from '@angular/forms';

// PrimeNG
import { CardModule } from 'primeng/card';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { CalendarModule } from 'primeng/calendar';
import { DropdownModule } from 'primeng/dropdown';
import { CheckboxModule } from 'primeng/checkbox';
import { RadioButtonModule } from 'primeng/radiobutton';
import { SliderModule } from 'primeng/slider';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import { ToggleButtonModule } from 'primeng/togglebutton';
import { RatingModule } from 'primeng/rating';
import { ProgressBarModule } from 'primeng/progressbar';
import { FileUploadModule } from 'primeng/fileupload';
import { TableModule } from 'primeng/table';
import { DatePicker } from 'primeng/datepicker';
import { Select } from 'primeng/select';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [
    HttpClientModule,
    CommonModule,
    FormsModule,
    ReactiveFormsModule,
    CardModule,
    ButtonModule,
    InputTextModule,
    CalendarModule,
    DropdownModule,
    CheckboxModule,
    RadioButtonModule,
    SliderModule,
    ToggleButtonModule,
    RatingModule,
    ProgressBarModule,
    FileUploadModule,
    TableModule,
    ProgressSpinnerModule,
    DatePicker,
    Select
  ],
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent {
  loginForm: FormGroup;
  submitted = false;

  constructor(private fb: FormBuilder) {
    this.loginForm = this.fb.group({
      username: ['', [Validators.required, Validators.minLength(3)]],
      password: ['', [Validators.required, Validators.minLength(6)]]
    });
  }

  get f() { return this.loginForm.controls; }

  onSubmit() {
    this.submitted = true;
    if (this.loginForm.valid) {
      console.log("Login successful!", this.loginForm.value);
    }
  }
}