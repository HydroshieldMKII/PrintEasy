import { Component, Input, Output, EventEmitter, inject } from '@angular/core';
import { ImportsModule } from '../../../imports';	
import { ContestModel } from '../../models/contest.model';
import { ContestService } from '../../services/contest.service';
import { AuthService } from '../../services/authentication.service';
import { MessageService } from 'primeng/api';
import { Router, RouterLink } from '@angular/router';
import { TranslatePipe } from '@ngx-translate/core';

@Component({
  selector: 'app-contest-card',
  imports: [ImportsModule, RouterLink, TranslatePipe],
  templateUrl: './contest-card.component.html',
  styleUrl: './contest-card.component.css'
})
export class ContestCardComponent {
  readonly authService = inject(AuthService);

  @Input() contest!: ContestModel;
  @Output() deleteContestEvent = new EventEmitter<number>();

  deleteDialogVisible: boolean = false;
  contestId: number = 0;

  constructor(
    private contestService: ContestService,
    private route: Router, 
    private messageService: MessageService
  ) { }

  editContest(contest: ContestModel) {
    if (contest.finished) {
      this.messageService.add({ severity: 'error', summary: 'Error', detail: 'Cannot edit a finished contest' });
    } else {
      this.route.navigate(['/contest', contest.id]);
    }
  }

  deleteContest(id: number) {
    this.contestId = id;
    this.deleteDialogVisible = true;
  }

  confirmDelete() {
    this.contestService.deleteContest(this.contestId).subscribe(() => {
      this.deleteContestEvent.emit(this.contestId);
      this.deleteDialogVisible = false;
    });
  }
}
