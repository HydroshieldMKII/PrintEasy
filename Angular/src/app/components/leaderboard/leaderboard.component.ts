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
    this.leaderboard = [
      {
        username: 'user1',
        wins: 10,
        participations: 20,
        winRate: 0.5,
        totalLikes: 10
      }
    ];

    this.userLeaderboardService.getUserLeaderboard().subscribe((leaderboard: UserLeaderboardModel[]) => {
      this.usersLeaderboard = leaderboard;
      console.log(this.usersLeaderboard)
    });
  }
}
