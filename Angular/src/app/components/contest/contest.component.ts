import { Component } from '@angular/core';
import { Contest } from '../../models/contest';

import { CardModule } from 'primeng/card';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-contest',
  standalone: true,
  imports: [CardModule, ButtonModule, InputTextModule, FormsModule, CommonModule],
  templateUrl: './contest.component.html',
  styleUrls: ['./contest.component.css']
})
export class ContestComponent {
  contests: Contest[] = [
    new Contest(
      1,
      'Animals',
      "Here, even lions go 3D, but without the mane, it's just a cat!",
      50,
      null,
      new Date('2024-03-01'),
      new Date('2024-04-01')
    ),
    new Contest(
      2,
      'Vehicles',
      'Design your dream car in 3D!',
      100,
      null,
      new Date('2024-03-10'),
      new Date('2024-04-10')
    )
  ];

  searchTerm: string = '';

  filterContests(): Contest[] {
    return this.contests.filter(contest =>
      contest.theme.toLowerCase().includes(this.searchTerm.toLowerCase())
    );
  }

  editContest(id: number) {
    console.log('Edit contest:', id);
  }

  deleteContest(id: number) {
    this.contests = this.contests.filter(contest => contest.id !== id);
  }
}
