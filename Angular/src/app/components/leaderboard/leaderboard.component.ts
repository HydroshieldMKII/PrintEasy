import { Component, inject } from '@angular/core';
import { ImportsModule } from '../../../imports';
import { TranslatePipe } from '@ngx-translate/core';
import { Router } from '@angular/router';

import { UserLeaderboardService } from '../../services/user-leaderboard.service';
import { MessageService } from 'primeng/api';
import { TranslateService } from '@ngx-translate/core';
import { UserLeaderboardModel } from '../../models/user-leaderboard.model';
import { SelectItem } from 'primeng/api';
import { filter } from 'rxjs';

@Component({
  selector: 'app-leaderboard',
  imports: [ImportsModule, TranslatePipe],
  templateUrl: './leaderboard.component.html',
  styleUrl: './leaderboard.component.css'
})
export class LeaderboardComponent {
  userLeaderboardService: UserLeaderboardService = inject(UserLeaderboardService);
  messageService = inject(MessageService);
  translateService = inject(TranslateService);
  route = inject(Router);

  usersLeaderboard: UserLeaderboardModel[] = [];
  currentFilter: string = '';
  currentEndDate: Date = new Date();
  currentStartDate: Date = new Date();
  currentSort: string = '';
  currentSortCategory: string = '';
  minDate: Date = new Date(2000, 0, 1);
  maxDate = new Date();

  filterOptions: SelectItem[] = [];
  sortOptions: SelectItem[] = [];
  
  selectedSortOption: SelectItem | null = null;
  selectedFilterOption: SelectItem | null = null;

  constructor() {
    this.translateService.onLangChange.subscribe(() => {
      this.translateRefresh();
    });
    this.translateRefresh();

    this.userLeaderboardService.getUserLeaderboard().subscribe((leaderboard: UserLeaderboardModel[]) => {
      this.usersLeaderboard = leaderboard;
    });
  }

  translateRefresh() {
    this.sortOptions = [
      { label: this.translateService.instant('leaderboard.sort.wins-asc'), value: 'wins-asc' },
      { label: this.translateService.instant('leaderboard.sort.wins-desc'), value: 'wins-desc' },
      { label: this.translateService.instant('leaderboard.sort.participations-asc'), value: 'participations-asc' },
      { label: this.translateService.instant('leaderboard.sort.participations-desc'), value: 'participations-desc' },
      { label: this.translateService.instant('leaderboard.sort.winrate-asc'), value: 'winrate-asc' },
      { label: this.translateService.instant('leaderboard.sort.winrate-desc'), value: 'winrate-desc' },
      { label: this.translateService.instant('leaderboard.sort.total-likes-asc'), value: 'total-likes-asc' },
      { label: this.translateService.instant('leaderboard.sort.total-likes-desc'), value: 'total-likes-desc' },
      { label: this.translateService.instant('leaderboard.sort.submission-ratio-asc'), value: 'submission-ratio-asc' },
      { label: this.translateService.instant('leaderboard.sort.submission-ratio-desc'), value: 'submission-ratio-desc' },
    ];
  }

  onStartChange(event: any) {
    const parsedDate = new Date(event).toISOString().slice(0, 10);
    this.currentStartDate = new Date(parsedDate);

    console.log(this.currentStartDate);

    this.route.navigate([], {
      queryParams: { startDate: this.currentStartDate || null },
      queryParamsHandling: 'merge'
    });

    // this.fetchContests();
  }

  onEndChange(event: any) {
    this.currentEndDate = event.value;

    console.log(event);

    this.route.navigate([], {
      queryParams: { endDate: this.currentEndDate || null },
      queryParamsHandling: 'merge'
    });

    // this.fetchContests();
  }

  onSortChange(event: any) {
    if (event?.value?.value) {
      this.currentSortCategory = event.value.value.split('-')[0];
      this.currentSort = event.value.value.split('-')[1];
    } else {
      this.currentSortCategory = '';
      this.currentSort = '';
    }

    this.route.navigate([], {
      queryParams: { sortCategory: this.currentSortCategory || null, sort: this.currentSort || null },
      queryParamsHandling: 'merge'
    });

    // this.fetchContests();
  }

  sf() {
    let sf_params = {};

    if (this.currentFilter) {
      sf_params = { ...sf_params, year: this.currentFilter };
    }
  }
}
