import { Component, inject } from '@angular/core';
import { ImportsModule } from '../../../imports';

import { UserLeaderboardService } from '../../services/user-leaderboard.service';
import { UserLeaderboardModel } from '../../models/user-leaderboard.model';

@Component({
  selector: 'app-leaderboard',
  imports: [ImportsModule],
  templateUrl: './leaderboard.component.html',
  styleUrl: './leaderboard.component.css'
})
export class LeaderboardComponent {
  leaderboard!: any[];
  userLeaderboardService: UserLeaderboardService = inject(UserLeaderboardService);

  usersLeaderboard: UserLeaderboardModel[] = [];

  constructor() {
    this.userLeaderboardService.getUserLeaderboard().subscribe((leaderboard: UserLeaderboardModel[]) => {
      this.usersLeaderboard = leaderboard;
    });
  }
}
