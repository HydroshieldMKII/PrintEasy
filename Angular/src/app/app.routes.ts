import { Routes } from '@angular/router';
import { HomeComponent } from './components/home/home.component';
import { LoginComponent } from './components/login/login.component';
import { SignupComponent } from './components/signup/signup.component';
import { NotfoundComponent } from './components/notfound/notfound.component';
import { ContestComponent } from './components/contest/contest.component';
import { UserProfileComponent } from './components/user-profile/user-profile.component';
import { ContestFormComponent } from './components/contest-form/contest-form.component';
import { RequestsComponent } from './components/request/request.component';
import { RequestFormComponent } from './components/request-form/request-form.component';
import { OffersComponent } from './components/offer/offer.component';
import { OrderComponent } from './components/order/order.component';
import { OrdersComponent } from './components/orders/orders.component';
import { SubmissionComponent } from './components/submission/submission.component';
import { SubmissionsComponent } from './components/submissions/submissions.component';
import { SubmissionFormComponent } from './components/submission-form/submission-form.component';

import { AuthenticationGuard } from './guards/authentication.guard';
import { ContestGuard } from './guards/contest.guard';

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
    path: 'offers',
    component: OffersComponent,
    title: 'Offers',
    canActivate: [AuthenticationGuard]
  },
  {
    path: '',
    canActivateChild: [ContestGuard],
    children: [
      {
        path: 'contest',
        component: ContestComponent,
        title: 'Contest',
      },
      {
        path: 'contest/new',
        component: ContestFormComponent,
        title: 'New Contest',
      },
      {
        path: 'contest/:id',
        component: ContestFormComponent,
        title: 'Edit Contest',
      },
      {
        path: 'contest/:id/submissions',
        component: SubmissionsComponent,
        title: 'Submissions',
      }
    ]
  },
  {
    path: '', 
    children: [
      {
        path: 'submission/new',
        component: SubmissionFormComponent,
        title: 'New Submission',
      },
      {
        path: 'submission/:id',
        component: SubmissionComponent,
        title: 'Submission',
      }
    ]
  },
  {
    path: 'profile',
    component: UserProfileComponent,
    title: 'Profile',
  },
  {
    path: 'orders',
    canActivate: [AuthenticationGuard],
    children: [
      {
        path: '',
        component: OrdersComponent,
        title: 'Orders'
      },
      {
        path: 'view/:id',
        component: OrderComponent,
        title: 'Order'
      }
    ]
  },
  {
    path: '**',
    component: NotfoundComponent,
    title: 'Not found',
    canActivate: [AuthenticationGuard]
  }
];
