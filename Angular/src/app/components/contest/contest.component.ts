import { Component, inject, Renderer2 } from '@angular/core';
import { TranslatePipe } from '@ngx-translate/core';
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
import { MessageService } from 'primeng/api';

@Component({
  selector: 'app-contest',
  standalone: true,
  imports: [CardModule, ButtonModule, InputTextModule, FormsModule, CommonModule, SpeedDialModule, DialogModule, RouterLink, TranslatePipe],
  templateUrl: './contest.component.html',
  styleUrls: ['./contest.component.css']
})
export class ContestComponent {
  route = inject(Router);
  contestService = inject(ContestService);
  authService = inject(AuthService);
  messageService = inject(MessageService);

  contests: ContestModel[] = [];
  id: number = 0;
  deleteDialogVisible: boolean = false;

  constructor(private renderer: Renderer2) {
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

  editContest(contest: ContestModel) {
    if (contest.finished) {
      this.messageService.add({ severity: 'error', summary: 'Error', detail: 'Cannot edit a finished contest' });
    } else {
      this.route.navigate(['/contest', contest.id]);
    }
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
