import { Component, inject, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule, FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { TranslatePipe } from '@ngx-translate/core';
import { Router, RouterModule } from '@angular/router';
import { UserCredentialsModel } from '../../models/user-credentials.model';
import { AuthService } from '../../services/authentication.service';

import { InputTextModule } from 'primeng/inputtext';
import { ButtonModule } from 'primeng/button';
import { CardModule } from 'primeng/card';
import { MessageModule } from 'primeng/message';
import { PasswordModule } from 'primeng/password';
import { DividerModule } from 'primeng/divider';
import { SelectModule } from 'primeng/select';
import { TagModule } from 'primeng/tag';

@Component({
  selector: 'app-signup',
  imports: [
    CommonModule,
    FormsModule,
    ReactiveFormsModule,
    DividerModule,
    RouterModule,
    InputTextModule,
    ButtonModule,
    CardModule,
    MessageModule,
    PasswordModule,
    TranslatePipe,
    SelectModule,
    TagModule
  ],
  templateUrl: './signup.component.html',
  styleUrls: ['./signup.component.css']
})
export class SignupComponent {
  router: Router = inject(Router);
  auth = inject(AuthService)
  credentials: UserCredentialsModel | null = null;
  signupForm: FormGroup;
  errors: any = {};
  countries: any[] = [
    { name: 'United States', countryId: 1 },
    { name: 'Canada', countryId: 2 },
    { name: 'France', countryId: 3 },
    { name: 'Germany', countryId: 4 },
    { name: 'Italy', countryId: 5 },
    { name: 'Spain', countryId: 6 },
    { name: 'United Kingdom', countryId: 7 },
    { name: 'Australia', countryId: 8 },
    { name: 'Brazil', countryId: 9 },
    { name: 'China', countryId: 10 },
    { name: 'India', countryId: 11 },
    { name: 'Japan', countryId: 12 },
    { name: 'Mexico', countryId: 13 },
    { name: 'Russia', countryId: 14 },
    { name: 'South Africa', countryId: 15 }
  ]
  selectedCountry: string = '';

  constructor(private fb: FormBuilder) {
    this.signupForm = this.fb.group({
      username: ['', Validators.required],
      password: ['', [Validators.required, Validators.minLength(6)]],
      confirmPassword: ['', [Validators.required, Validators.minLength(6)]],
      country: ['', Validators.required],
    }, { validator: this.passwordsMatch });
  }

  passwordsMatch(form: FormGroup) {
    const password = form.get('password')?.value;
    const confirmPassword = form.get('confirmPassword')?.value;
    return password === confirmPassword ? null : { mismatch: true };
  }

  onSubmit() {
    if (this.signupForm.valid) {
      // console.log('Signing up with:', this.signupForm.value);
      const countryId = this.countries.find(country => country.name === this.signupForm.value.country)?.countryId;
      this.credentials = new UserCredentialsModel(this.signupForm.value.username, this.signupForm.value.password, this.signupForm.value.confirmPassword, countryId);

      this.auth.signUp(this.credentials).subscribe((response) => {
        // console.log('Signup response:', response);
        if (response.status === 200) {
          this.router.navigate(['/']);
        } else {
          console.error('Signup errors:', response.errors);
          const currentLanguage = localStorage.getItem('language');
          switch (currentLanguage) {
            case 'en':
              if (response.errors['username']) {
                this.errors = { username: 'Username already taken' };
              }
              break;
            case 'fr':
              if (response.errors['username']) {
                this.errors = { username: 'Nom d\'utilisateur déjà pris' };
              }
              break;
            default:
              this.errors = { general: 'An unexpected error occured' };
              break;
          }
        }
      });

    }
  }

  hasErrors() {
    return Object.keys(this.errors).length > 0;
  }
}
