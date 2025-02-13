import { Component, inject } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { TranslatePipe } from '@ngx-translate/core';

import { AuthService } from '../../services/authentication.service';
import { UserCredentialsModel } from '../../models/user-credentials.model';;

import { InputTextModule } from 'primeng/inputtext';
import { PasswordModule } from 'primeng/password';
import { ButtonModule } from 'primeng/button';
import { CardModule } from 'primeng/card';
import { MessageModule } from 'primeng/message';
import { ToastModule } from 'primeng/toast';

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
    MessageModule,
    ToastModule,
    TranslatePipe
  ],
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css'],
})
export class LoginComponent {
  private readonly auth = inject(AuthService)
  router: Router = inject(Router);
  errors: any = {};
  loginForm: FormGroup;
  credentials: UserCredentialsModel | null = null;

  constructor(private fb: FormBuilder) {
    this.loginForm = this.fb.group({
      username: ['', Validators.required],
      password: ['', Validators.required]
    });
  }

  onSubmit() {
    if (this.loginForm.valid) {
      // console.log('Logging in with:', this.loginForm.value);
      this.credentials = new UserCredentialsModel(this.loginForm.value.username, this.loginForm.value.password);

      this.auth.logIn(this.credentials).subscribe((response) => {
        // console.log('Login response:', response);
        if (response.status === 200) {
          this.router.navigate(['/']);
        } else {
          const currentLanguage = localStorage.getItem('language');

          switch (currentLanguage) {
            case 'en':
              if (response.errors['connection']) {
                this.errors = { connection: 'Invalid username or password' };
              }
              break;
            case 'fr':
              if (response.errors['connection']) {
                this.errors = { connection: 'Nom d\'utilisateur ou mot de passe invalide' };
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