import { Routes } from '@angular/router';
import { HomeComponent } from './components/home/home.component';
import { LoginComponent } from './components/login/login.component';
import { SignupComponent } from './components/signup/signup.component';
import { NotfoundComponent } from './components/notfound/notfound.component';
import { RequestsComponent } from './components/request/request.component';
import { RequestFormComponent } from './components/request-form/request-form.component';

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
  {
    path: 'requests',
    component: RequestsComponent,
    title: 'Request',
  },
  {
    path: 'request-form',
    component: RequestFormComponent,
    title: 'Request Form',
  },
  {
    path: '**',
    component: NotfoundComponent,
    title: 'Not found',
    canActivate: [AuthenticationGuard]
  }
];
