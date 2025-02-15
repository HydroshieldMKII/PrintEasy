import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';

import { AvatarModule } from 'primeng/avatar';
import { RatingModule } from 'primeng/rating';
import { TabViewModule } from 'primeng/tabview';
import { FormsModule } from '@angular/forms';

import { AuthService } from '../../services/authentication.service';

@Component({
  selector: 'app-user-profile',
  imports: [AvatarModule, RatingModule, TabViewModule, FormsModule, CommonModule],
  templateUrl: './user-profile.component.html',
  styleUrl: './user-profile.component.css'
})
export class UserProfileComponent {
  readonly authService = inject(AuthService);

  rating = 0;
  reviews = 0;
  prints = 3;
  joinDate = '2022-05-11';
}
