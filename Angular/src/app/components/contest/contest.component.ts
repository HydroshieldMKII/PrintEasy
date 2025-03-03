import { Component, inject, Renderer2, OnInit } from '@angular/core';
import { TranslatePipe } from '@ngx-translate/core';
import { ContestModel } from '../../models/contest.model';
import { Router, RouterLink, ActivatedRoute } from '@angular/router';
import { ContestService } from '../../services/contest.service';
import { AuthService } from '../../services/authentication.service';

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

@Component({
  selector: 'app-contest',
  standalone: true,
  imports: [CardModule, ButtonModule, InputTextModule, FormsModule, CommonModule, SpeedDialModule, DialogModule, RouterLink, TranslatePipe, SelectModule, FloatLabelModule],
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
  currentFilter: string = '';
  currentSort: string = '';
  currentSortCategory: string = '';
  currentQuery: string = '';

  filterOptions: SelectItem[] =  [
    { label: 'All', value: '' },
    { label: 'Active', value: 'active' },
    { label: 'Finished', value: 'finished' }
  ];
  sortOptions: SelectItem[] = [
    { label: 'None', value: '' },
    { label: 'Submissions (Asc)', value: 'submissions-asc' },
    { label: 'Submissions (Desc)', value: 'submissions-desc' },
    { label: 'Start Date (Asc)', value: 'start_at-asc' },
    { label: 'Start Date (Desc)', value: 'start_at-desc' },
  ];

  selectedSortOption: SelectItem | null = null;
  selectedFilterOption: SelectItem | null = null;

  constructor(private renderer: Renderer2, private activatedRoute: ActivatedRoute) {
    this.activatedRoute.queryParams.subscribe(params => {
      this.currentFilter = params['filter'] || 'all';
      this.currentSort = params['sort'] || '';
      this.currentSortCategory = params['sortCategory'] || '';
      this.currentQuery = params['search'] || '';

      this.selectedFilterOption = this.filterOptions.find(option => option.value === this.currentFilter) || this.filterOptions[0];
      this.selectedSortOption = this.sortOptions.find(option => option.value === `${this.currentSortCategory}-${this.currentSort}`) || this.sortOptions[0];
    });

    this.fetchContests();
  }

  searchTerm: string = '';

  ssf() {
    let ssf_params: {  } = { };

    if (this.currentFilter === 'active') {
      ssf_params = { ...ssf_params, active: true };
    } else if (this.currentFilter === 'finished') {
      ssf_params = { ...ssf_params, finished: true };
    }

    return ssf_params;
  }

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
    this.contestService.deleteContest(this.id).subscribe((data) => {
      this.deleteDialogVisible = false;
      this.contests = this.contests.filter(contest => contest.id !== this.id);
    }
    );
  }

  deleteContest(id: number) {
    this.id = id;
    this.deleteDialogVisible = true;
  }

  onFilterChange(event: any) {
    this.currentFilter = event.value.value;

    this.route.navigate([], {
      queryParams: { filter: this.currentFilter || null },
      queryParamsHandling: 'merge'
    });

    this.fetchContests();
  }

  onSortChange(event: any) {
    if (event.value.value) {
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
  }

  onSearch() {
    this.route.navigate([], {
      queryParams: { search: this.searchTerm || null },
      queryParamsHandling: 'merge'
    });
  }

  fetchContests() {
    this.contestService.getContests(this.ssf()).subscribe((response) => {
      console.log('Contests:', response);
      this.contests = response;
    }
    );
  }
}
