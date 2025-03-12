import { Component, inject } from '@angular/core';
import { ImportsModule } from '../../../imports';
import { TranslatePipe } from '@ngx-translate/core';
import { Router, ActivatedRoute } from '@angular/router';

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
  startDate = new Date(2000, 0, 1);
  endDate = new Date();

  filterOptions: SelectItem[] = [];
  sortOptions: SelectItem[] = [];
  
  selectedSortOption: SelectItem | null = null;
  selectedFilterOption: SelectItem | null = null;

  constructor(private activatedRoute: ActivatedRoute) {
    this.translateService.onLangChange.subscribe(() => {
      this.translateRefresh();
    });
    this.translateRefresh();

    this.activatedRoute.queryParams.subscribe(params => {
      this.currentFilter = params['filter'] || '';
      this.currentStartDate = params['startDate'] || '';
      this.currentEndDate = params['endDate'] || '';
      this.currentSortCategory = params['sortCategory'] || '';
      this.currentSort = params['sort'] || '';
    });

    //TOCHECK setHours(0, 0, 0, 0)
    if (this.currentEndDate) {
      this.endDate = new Date(new Date(this.currentEndDate).setUTCHours(12, 0, 0, 0));
    }

    if (this.currentStartDate) {
      this.startDate = new Date(new Date(this.currentStartDate).setUTCHours(12, 0, 0, 0));
    }

    this.selectedSortOption = this.sortOptions.find(option => option.value === `${this.currentSortCategory}-${this.currentSort}`) || null;

    this.fetchLeaderboard();
  }

  translateRefresh() {
    this.sortOptions = [
      { label: this.translateService.instant('leaderboard.sort.wins-asc'), value: 'wins-asc' },
      { label: this.translateService.instant('leaderboard.sort.wins-desc'), value: 'wins-desc' },
      { label: this.translateService.instant('leaderboard.sort.participations-asc'), value: 'participations-asc' },
      { label: this.translateService.instant('leaderboard.sort.participations-desc'), value: 'participations-desc' },
      { label: this.translateService.instant('leaderboard.sort.winrate-asc'), value: 'winrate-asc' },
      { label: this.translateService.instant('leaderboard.sort.winrate-desc'), value: 'winrate-desc' },
      { label: this.translateService.instant('leaderboard.sort.total-likes-asc'), value: 'total_likes-asc' },
      { label: this.translateService.instant('leaderboard.sort.total-likes-desc'), value: 'total_likes-desc' },
      { label: this.translateService.instant('leaderboard.sort.submission-ratio-asc'), value: 'submission_rate-asc' },
      { label: this.translateService.instant('leaderboard.sort.submission-ratio-desc'), value: 'submission_rate-desc' },
    ];
  }

  onStartChange(event: Date) {
    this.currentStartDate = event;

    this.route.navigate([], {
      queryParams: { startDate: this.currentStartDate.toISOString().split('T')[0] || null },
      queryParamsHandling: 'merge'
    });

    this.fetchLeaderboard();
  }

  onEndChange(event: Date) {
    this.currentEndDate = event;
    
    this.route.navigate([], {
      queryParams: { endDate: this.currentEndDate.toISOString().split('T')[0] || null },
      queryParamsHandling: 'merge'
    });

    this.fetchLeaderboard();
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

    this.fetchLeaderboard();
  }

  sf() {
    let sf_params = {};

    if (this.currentStartDate) {
      sf_params = { ...sf_params, start_date: new Date(this.currentStartDate).toISOString().split('T')[0] };	
    }

    if (this.currentEndDate) {
      sf_params = { ...sf_params, end_date: new Date(this.currentEndDate).toISOString().split('T')[0] };	
    }

    if (this.currentSortCategory) {
      sf_params = { ...sf_params, category: this.currentSortCategory };	
    }

    if (this.currentSort) {
      sf_params = { ...sf_params, direction: this.currentSort };	
    }
    console.log(sf_params);
    return sf_params;
  }

  fetchLeaderboard() {
    this.userLeaderboardService.getUserLeaderboard(this.sf()).subscribe((leaderboard: UserLeaderboardModel[]) => {
      this.usersLeaderboard = leaderboard;
    });
  }
}
