import { Component, inject } from '@angular/core';
import { Router, RouterLink, ActivatedRoute } from '@angular/router';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';

import { AuthService } from '../../services/authentication.service';
import { UserCredentialsModel } from '../../models/user-credentials.model';
import { RequestResponseModel } from '../../models/request-response.model';

import { MessageService } from 'primeng/api';
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
  private readonly auth = inject(AuthService)
  router: Router = inject(Router);
  route: ActivatedRoute = inject(ActivatedRoute);
  success: boolean = true || null;
  loginForm: FormGroup;
  credentials: UserCredentialsModel | null = null;
  messagingService: MessageService;

  constructor(private fb: FormBuilder, messageService: MessageService) {
    this.loginForm = this.fb.group({
      username: ['', Validators.required],
      password: ['', Validators.required]
    });
    this.messagingService = messageService;
    this.route.queryParams.subscribe(params => {
      if (params['logout'] === 'success') {
        this.messagingService?.add({ severity: 'success', summary: 'Logged out', detail: 'You have been logged out successfully' });
      }
    });
  }

  onSubmit() {
    if (this.loginForm.valid) {
      console.log('Logging in with:', this.loginForm.value);
      this.credentials = new UserCredentialsModel(this.loginForm.value.username, this.loginForm.value.password);

      this.auth.logIn(this.credentials).subscribe((response) => {
        if (response.status === 200) {
          console.log('Login successful');
          //set local storage
          this.success = true;

        } else {
          this.success = false;
        }
      });
    }
  }
}