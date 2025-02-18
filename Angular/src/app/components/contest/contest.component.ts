import { Component, inject } from '@angular/core';
import { ContestModel } from '../../models/contest.model';
import { Router, RouterLink } from '@angular/router';
import { ContestService } from '../../services/contest.service';

import { CardModule } from 'primeng/card';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { SpeedDialModule } from 'primeng/speeddial';

@Component({
  selector: 'app-contest',
  standalone: true,
  imports: [CardModule, ButtonModule, InputTextModule, FormsModule, CommonModule, SpeedDialModule],
  templateUrl: './contest.component.html',
  styleUrls: ['./contest.component.css']
})
export class ContestComponent {
  route = inject(Router);
  contestService = inject(ContestService);
  contests: ContestModel[] = [];

  constructor() {
    this.contestService.getContests().subscribe((response) => {
      console.log('Contests:', response);
      this.contests = response;
    });
  }
  searchTerm: string = '';

  newContest() {
    console.log('New contest');
    this.route.navigate(['/contest/new']);
  }

  filterContests(): ContestModel[] {
    return this.contests.filter(contest =>
      contest.theme.toLowerCase().includes(this.searchTerm.toLowerCase())
    );
  }

  editContest(id: number) {
    console.log("Edit contest", id);
    this.route.navigate(['/contest', id]);
  }

  deleteContest(id: number) {
    this.contests = this.contests.filter(contest => contest.id !== id);
  }
}
