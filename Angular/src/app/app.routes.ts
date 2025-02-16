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
    title: 'Login'
  },
  {
    path: 'signup',
    component: SignupComponent,
    title: 'Sign up'
  },
  {
    path: 'requests',
    canActivate: [AuthenticationGuard],
    children: [
      {
        path: '',
        component: RequestsComponent,
        title: 'Request'
      },
      {
        path: 'view/:id',
        component: RequestFormComponent,
        title: 'Request'
      },
      {
        path: 'edit/:id',
        component: RequestFormComponent,
        title: 'Request'
      },
      {
        path: 'new',
        component: RequestFormComponent,
        title: 'Request'
      }
    ]
  },
  {
    path: '**',
    component: NotfoundComponent,
    title: 'Not found'
  }
];
