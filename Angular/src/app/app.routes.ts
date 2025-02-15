import { Routes } from '@angular/router';
import { HomeComponent } from './components/home/home.component';
import { LoginComponent } from './components/login/login.component';
import { SignupComponent } from './components/signup/signup.component';
import { NotfoundComponent } from './components/notfound/notfound.component';
import { ContestComponent } from './components/contest/contest.component';
import { UserProfileComponent } from './components/user-profile/user-profile.component';

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
    path: 'contest',
    component: ContestComponent,
    title: 'Contest',
  },
  {
    path: 'profile',
    component: UserProfileComponent,
    title: 'Profile',
  }, 
  {
    path: '**',
    component: NotfoundComponent,
    title: 'Not found',
    canActivate: [AuthenticationGuard]
  }
];
