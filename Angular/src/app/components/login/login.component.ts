import { Component, inject } from '@angular/core';
import { RouterLink } from '@angular/router';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';

import { AuthService } from '../../services/authentication.service';
import { UserCredentialsModel } from '../../models/user-credentials.model';
import { RequestResponseModel } from '../../models/request-response.model';


import { InputTextModule } from 'primeng/inputtext';
import { PasswordModule } from 'primeng/password';
import { ButtonModule } from 'primeng/button';
import { CardModule } from 'primeng/card';
import { MessageModule } from 'primeng/message';

@Component({
  selector: 'app-login',
  imports: [
    CommonModule,
    RouterLink,
    ReactiveFormsModule,
    InputTextModule,
    PasswordModule,
    ButtonModule,
    CardModule,
    MessageModule
  ],
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent {
  success: boolean = true || null;
  loginForm: FormGroup;
  credentials: UserCredentialsModel | null = null;

  private readonly auth = inject(AuthService)

  constructor(private fb: FormBuilder) {
    this.loginForm = this.fb.group({
      username: ['', Validators.required],
      password: ['', Validators.required]
    });
  }

  onSubmit() {
    if (this.loginForm.valid) {
      console.log('Logging in with:', this.loginForm.value);

      this.credentials = new UserCredentialsModel(this.loginForm.value.username, this.loginForm.value.password);

      this.auth.logIn(this.credentials).subscribe((response) => {
        if (response.status === 200) {
          console.log('Login successful');
        } else {
          this.success = false;
        }
      });
    }
  }
}