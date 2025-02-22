import { Component, inject } from '@angular/core';
import { ContestModel } from '../../models/contest.model';
import { Router, RouterLink } from '@angular/router';
import { ContestService } from '../../services/contest.service';
import { AuthService } from '../../services/authentication.service';

import { CardModule } from 'primeng/card';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { SpeedDialModule } from 'primeng/speeddial';
import { DialogModule } from 'primeng/dialog';

@Component({
  selector: 'app-contest',
  standalone: true,
  imports: [CardModule, ButtonModule, InputTextModule, FormsModule, CommonModule, SpeedDialModule, DialogModule, RouterLink],
  templateUrl: './contest.component.html',
  styleUrls: ['./contest.component.css']
})
export class ContestComponent {
  route = inject(Router);
  contestService = inject(ContestService);
  authService = inject(AuthService);

  contests: ContestModel[] = [];
  id: number = 0;
  deleteDialogVisible: boolean = false;

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

  confirmDelete() {
    this.contestService.deleteContest(this.id).subscribe(() => {
      this.deleteDialogVisible = false;
      this.contests = this.contests.filter(contest => contest.id !== 1);
    }
    );
  }

  deleteContest(id: number) {
    this.id = id;
    this.deleteDialogVisible = true;
  }
}
