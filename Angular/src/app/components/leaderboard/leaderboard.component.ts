import { Component } from '@angular/core';
import { ImportsModule } from '../../../imports';

@Component({
  selector: 'app-leaderboard',
  imports: [ImportsModule],
  templateUrl: './leaderboard.component.html',
  styleUrl: './leaderboard.component.css'
})
export class LeaderboardComponent {
  leaderboard!: any[];

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
  }
}
