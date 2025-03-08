import { Component, inject, Renderer2, OnInit } from '@angular/core';
import { TranslatePipe } from '@ngx-translate/core';
import { ContestModel } from '../../models/contest.model';
import { Router, RouterLink, ActivatedRoute } from '@angular/router';
import { ContestService } from '../../services/contest.service';
import { AuthService } from '../../services/authentication.service';
import { TranslateService } from '@ngx-translate/core';

import { CardModule } from 'primeng/card';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { SpeedDialModule } from 'primeng/speeddial';
import { DialogModule } from 'primeng/dialog';
import { MessageService, SelectItem } from 'primeng/api';
import { Select, SelectModule } from 'primeng/select';
import { FloatLabelModule } from 'primeng/floatlabel';
import { SliderModule } from 'primeng/slider';
import { Slider } from 'primeng/slider';
import { ContestCardComponent } from '../contest-card/contest-card.component';

@Component({
  selector: 'app-contest',
  standalone: true,
  imports: [CardModule, ButtonModule, InputTextModule, FormsModule, CommonModule, SpeedDialModule, DialogModule, RouterLink, TranslatePipe, SelectModule, FloatLabelModule, SliderModule, Slider, ContestCardComponent],
  templateUrl: './contest.component.html',
  styleUrls: ['./contest.component.css']
})
export class ContestComponent {
  route = inject(Router);
  contestService = inject(ContestService);
  authService = inject(AuthService);
  messageService = inject(MessageService);
  translateService = inject(TranslateService);

  contests: ContestModel[] = [];
  id: number = 0;
  deleteDialogVisible: boolean = false;
  currentFilter: string = '';
  currentSort: string = '';
  currentSortCategory: string = '';
  currentQuery: string = '';
  currentValues: number[] = [0, 30];
  oldCurrentValues: number[] = [0, 30];
  sliderClass: string = 'none';
  showAdvancedFilters: boolean = false;

  filterOptions: SelectItem[] = [
    { label: this.translateService.instant('contest.ssf.filter.active'), value: 'active' },
    { label: this.translateService.instant('contest.ssf.filter.inactive'), value: 'finished' }
  ];
  sortOptions: SelectItem[] = [
    { label: this.translateService.instant('contest.ssf.sort.participants_asc'), value: 'submissions-asc' },
    { label: this.translateService.instant('contest.ssf.sort.participants_desc'), value: 'submissions-desc' },
    { label: this.translateService.instant('contest.ssf.sort.start_asc'), value: 'start_at-asc' },
    { label: this.translateService.instant('contest.ssf.sort.start_desc'), value: 'start_at-desc' },
  ];

  selectedSortOption: SelectItem | null = null;
  selectedFilterOption: SelectItem | null = null;

  constructor(private renderer: Renderer2, private activatedRoute: ActivatedRoute) {
    this.activatedRoute.queryParams.subscribe(params => {
      this.currentFilter = params['filter'] || 'all';
      this.currentSort = params['sort'] || '';
      this.currentSortCategory = params['sortCategory'] || '';
      this.currentQuery = params['search'] || '';
      if (params['participants'] && Array.isArray(params['participants'])) {
        this.currentValues = params['participants'];

        if (this.currentValues[0] > this.currentValues[1]) {
          const [minValue, maxValue] = [Math.min(this.currentValues[0], this.currentValues[1]), Math.max(this.currentValues[0], this.currentValues[1])];
          this.currentValues[0] = minValue;
          this.currentValues[1] = maxValue;
        }
      } else {
        this.currentValues = [0, 30];
        this.route.navigate([], {
          queryParams: { participants: null },
          queryParamsHandling: 'merge'
        });
      }

      this.selectedFilterOption = this.filterOptions.find(option => option.value === this.currentFilter) || null;
      this.selectedSortOption = this.sortOptions.find(option => option.value === `${this.currentSortCategory}-${this.currentSort}`) || null;
    });

    this.fetchContests();
  }

  ssf() {
    let ssf_params: {} = {};

    if (this.currentFilter === 'active') {
      ssf_params = { ...ssf_params, active: true };
    } else if (this.currentFilter === 'finished') {
      ssf_params = { ...ssf_params, finished: true };
    }

    if (this.currentSort) {
      if (this.currentSortCategory === 'submissions') {
        ssf_params = { ...ssf_params, sort_by_submissions: this.currentSort };
      } else if (this.currentSortCategory === 'start_at') {
        ssf_params = { ...ssf_params, sort: this.currentSort, category: this.currentSortCategory };
      }
    }

    if (this.currentQuery) {
      ssf_params = { ...ssf_params, search: this.currentQuery };
    }

    if (this.currentValues[0] > 0 || this.currentValues[1] <= 30) {
      ssf_params = { ...ssf_params, participants_min: this.currentValues[0], participants_max: this.currentValues[1] };
    }

    return ssf_params;
  }

  onClearFilter() {
    debugger;
    this.currentFilter = '';
    this.selectedFilterOption = this.filterOptions[0];

    this.route.navigate([], {
      queryParams: { filter: null },
      queryParamsHandling: 'merge'
    });
  }

  onClearSort() {
    this.currentSort = '';
    this.currentSortCategory = '';
    this.selectedSortOption = this.sortOptions[0];

    this.route.navigate([], {
      queryParams: { sortCategory: null, sort: null },
      queryParamsHandling: 'merge'
    });
  }

  newContest() {
    this.route.navigate(['/contest/new']);
  }

  editContest(contest: ContestModel) {
    if (contest.finished) {
      this.messageService.add({ severity: 'error', summary: 'Error', detail: 'Cannot edit a finished contest' });
    } else {
      this.route.navigate(['/contest', contest.id]);
    }
  }

  confirmDelete() {
    this.contestService.deleteContest(this.id).subscribe((data) => {
      this.deleteDialogVisible = false;
      this.contests = this.contests.filter(contest => contest.id !== this.id);
    }
    );
  }

  onContestDeleted(contestId: number) {
    this.contests = this.contests.filter(contest => contest.id !== contestId);
  }

  deleteContest(id: number) {
    this.id = id;
    this.deleteDialogVisible = true;
  }

  onFilterChange(event: { value: SelectItem }) {
    this.currentFilter = event?.value?.value || '';

    this.route.navigate([], {
      queryParams: { filter: this.currentFilter || null },
      queryParamsHandling: 'merge'
    });

    this.fetchContests();
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

    this.fetchContests();
  }

  onSearch() {
    this.route.navigate([], {
      queryParams: { search: this.currentQuery || null },
      queryParamsHandling: 'merge'
    });

    this.fetchContests();
  }

  onSlideEnd(event: any) {
    if (this.oldCurrentValues[0] != this.currentValues[0] || this.oldCurrentValues[1] != this.currentValues[1]) {
      this.currentValues = event.values;

      if (this.currentValues[0] > this.currentValues[1]) {
        const [minValue, maxValue] = [Math.min(this.currentValues[0], this.currentValues[1]), Math.max(this.currentValues[0], this.currentValues[1])];
        this.currentValues[0] = minValue;
        this.currentValues[1] = maxValue;
      }

      this.route.navigate([], {
        queryParams: { participants: this.currentValues || null },
        queryParamsHandling: 'merge'
      });

      this.oldCurrentValues = this.currentValues;
      this.fetchContests();
    }
  }

  toggleAdvancedFilters() {
    this.showAdvancedFilters = !this.showAdvancedFilters;
  }

  fetchContests() {
    this.contestService.getContests(this.ssf()).subscribe((response) => {
      this.contests = response;
    }
    );
  }
}
