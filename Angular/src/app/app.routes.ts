import { Routes } from '@angular/router';
import { HomeComponent } from './home/home.component';
import { LoginComponent } from './components/login/login.component';
import { SignupComponent } from './components/signup/signup.component';

import { AuthenticationGuard } from './guards/authentication.guard';

export const routes: Routes = [
  {
    path: '',
    component: HomeComponent,
    title: 'Home',
    canActivate: [AuthenticationGuard]
  },
  {
    path: 'login',
    component: LoginComponent,
    title: 'Login',
    canActivate: [AuthenticationGuard]
  },
  {
    path: 'signup',
    component: SignupComponent,
    title: 'Sign up',
    canActivate: [AuthenticationGuard]
  },
];
