import { Component, OnInit } from '@angular/core';
import { SelectItem } from 'primeng/api';
import { Router, RouterLink } from '@angular/router';
import { RequestModel } from '../../models/request.model';
import { RequestService } from '../../services/request.service';
import { ImportsModule } from '../../../imports';
import { MessageService } from 'primeng/api';
import { Clipboard } from '@angular/cdk/clipboard';
import { TranslatePipe } from '@ngx-translate/core';
import { TranslateService } from '@ngx-translate/core';
import { ApiResponseModel } from '../../models/api-response.model';
import { SliderSlideEndEvent } from 'primeng/slider';
import { FilamentModel } from '../../models/filament.model';
import { ColorModel } from '../../models/color.model';

@Component({
  selector: 'app-request',
  imports: [ImportsModule, RouterLink, TranslatePipe],
  templateUrl: './request.component.html',
  styleUrls: ['./request.component.css']
})
export class RequestsComponent implements OnInit {
  activeTab: string = 'mine';
  requests: RequestModel[] | null = null;
  myRequests: RequestModel[] | null = null;

  deleteDialogVisible: boolean = false;
  requestToDelete: RequestModel | null = null;

  isOwningPrinter: boolean | null = null;
  expandedRows: { [key: number]: boolean } = {};
  expandedMyRows: { [key: number]: boolean } = {};
  searchQuery: string = '';
  currentFilter: string = '';
  currentSort: string = '';
  currentSortCategory: string = '';

  selectedSortOption: SelectItem | null = null;
  selectedFilterOption: SelectItem | null = null;

  filterOptions: SelectItem[] = [];
  sortOptions: SelectItem[] = [];

  budgetRange: number[] = [0, 10000];
  dateRange: any[] | null = null;

  currentLanguage: string = 'en';
  showAdvancedFilters: boolean = false;

  toggleAdvancedFilters(): void {
    this.showAdvancedFilters = !this.showAdvancedFilters;
  }

  constructor(
    private requestService: RequestService,
    private router: Router,
    private messageService: MessageService,
    private clipboard: Clipboard,
    private translate: TranslateService
  ) {
    const queryParams = this.router.parseUrl(this.router.url).queryParams;
    this.currentFilter = queryParams['filter'] || null;
    this.currentSort = queryParams['sort'] || null;
    this.currentSortCategory = queryParams['sortCategory'] || null;
    this.searchQuery = queryParams['search'] || null;

    // set tab
    this.activeTab = queryParams['tab'] || 'mine';
    this.router.navigate([], { queryParams: { tab: this.activeTab }, queryParamsHandling: 'merge' });

    this.translate.onLangChange.subscribe(() => {
      this.translateRefresh();
    });
    this.translateRefresh();
  }

  refreshData() {
    this.filter('all');
    this.filter('mine');
  }

  translateRefresh() {
    this.filterOptions = [
      { label: this.translate.instant('request.filter.owned-printer'), value: 'owned-printer' },
      { label: this.translate.instant('request.filter.country'), value: 'country' },
      { label: this.translate.instant('request.filter.in-progress'), value: 'in-progress' }
    ];

    this.sortOptions = [
      { label: this.translate.instant('global.sort.name-asc'), value: 'name-asc' },
      { label: this.translate.instant('global.sort.name-desc'), value: 'name-desc' },
      { label: this.translate.instant('global.sort.date-asc'), value: 'date-asc' },
      { label: this.translate.instant('global.sort.date-desc'), value: 'date-desc' },
      { label: this.translate.instant('global.sort.budget-asc'), value: 'budget-asc' },
      { label: this.translate.instant('global.sort.budget-desc'), value: 'budget-desc' },
      { label: this.translate.instant('global.sort.country-asc'), value: 'country-asc' },
      { label: this.translate.instant('global.sort.country-desc'), value: 'country-desc' }
    ];

    this.selectedFilterOption = this.filterOptions.find(option => option.value === this.currentFilter) || null;
    this.selectedSortOption = this.sortOptions.find(option => option.value === `${this.currentSortCategory}-${this.currentSort}`) || null;

    if (this.requests) {
      this.requests.forEach(request => {
        request.presets.forEach(preset => {
          preset.color.name = this.translateColor(preset.color.id);
          preset.filamentType.name = this.translateFilament(preset.filamentType.id);
        });
      });
    }

    if (this.myRequests) {
      this.myRequests.forEach(request => {
        request.presets.forEach(preset => {
          preset.color.name = this.translateColor(preset.color.id);
          preset.filamentType.name = this.translateFilament(preset.filamentType.id);
        });
      });
    }
  }

  ngOnInit(): void {
    this.currentLanguage = localStorage.getItem('language') || 'en';

    this.initBudgetRange();
    this.initDateRange();

    this.filter(this.activeTab);

    this.selectedFilterOption = this.filterOptions.find(option => option.value === this.currentFilter) || null;
    this.selectedSortOption = this.sortOptions.find(option => option.value === `${this.currentSortCategory}-${this.currentSort}`) || null;
  }

  initDateRange(): void {
    this.dateRange = null;

    const queryParams = this.router.parseUrl(this.router.url).queryParams;
    if (queryParams['startDate']) {
      const startDate = new Date(queryParams['startDate']);
      const endDate = queryParams['endDate'] ? new Date(queryParams['endDate']) : null;

      startDate.setUTCHours(12, 0, 0, 0);
      if (endDate) {
        endDate.setUTCHours(12, 0, 0, 0);
      }

      this.dateRange = [startDate, endDate];
    }
  }

  initBudgetRange(): void {
    this.budgetRange = [0, 10000];

    const queryParams = this.router.parseUrl(this.router.url).queryParams;
    if (queryParams['minBudget'] && queryParams['maxBudget']) {
      this.budgetRange = [
        parseInt(queryParams['minBudget']),
        parseInt(queryParams['maxBudget'])
      ];
    }
  }

  onTabChange(tab: string): void {
    this.activeTab = tab;
    this.router.navigate([], { queryParams: { tab: this.activeTab }, queryParamsHandling: 'merge' });

    if (this.activeTab === 'all' && !this.requests) {
      this.filter(this.activeTab);
    }
    if (this.activeTab === 'mine' && !this.myRequests) {
      this.filter(this.activeTab);
    }
  }

  get currentRequests(): RequestModel[] {
    return this.activeTab === 'mine' ? this.myRequests || [] : this.requests || [];
  }

  filter(type: string): void {
    const startDate = this.dateRange && this.dateRange[0] ? this.dateRange[0] : null;
    const endDate = this.dateRange && this.dateRange.length > 1 && this.dateRange[1] ? this.dateRange[1] : null;
    this.requestService
      .filter(
        this.currentFilter,
        this.currentSortCategory,
        this.currentSort,
        this.searchQuery,
        this.budgetRange[0],
        this.budgetRange[1],
        startDate,
        endDate,
        type
      )
      .subscribe((result: [RequestModel[], boolean] | ApiResponseModel) => {
        if (result instanceof ApiResponseModel) {
          return;
        }

        const [requests, isOwningPrinter] = result;

        if (this.isOwningPrinter === null) {
          this.isOwningPrinter = isOwningPrinter;
        }
        if (type === 'all') {
          this.requests = requests;
        } else if (type === 'mine') {
          this.myRequests = requests;
        }
      });
  }

  expandAll(): void {
    this.expandedRows = this.currentRequests.reduce((acc: { [key: number]: boolean }, request: RequestModel) => {
      acc[request.id] = true;
      return acc;
    }, {});
  }

  collapseAll(): void {
    this.expandedRows = {};
  }

  onRowExpand(event: any): void {
    this.expandedRows[event.data.id] = true;
  }

  onRowCollapse(event: any): void {
    delete this.expandedRows[event.data.id];
  }

  downloadRequest(downloadUrl: string): void {
    window.open(downloadUrl, '_blank');
  }

  showDeleteDialog(request: RequestModel): void {
    this.requestToDelete = request;
    this.deleteDialogVisible = true;
  }

  confirmDelete(): void {
    if (this.requestToDelete !== null) {
      this.requestService.deleteRequest(this.requestToDelete.id).subscribe(() => {
        this.requests = (this.requests || []).filter(r => r.id !== this.requestToDelete?.id);
        this.myRequests = (this.myRequests || []).filter(r => r.id !== this.requestToDelete?.id);
      });
    }
    this.deleteDialogVisible = false;
  }

  onSearch(): void {
    this.router.navigate([], { queryParams: { search: this.searchQuery || null }, queryParamsHandling: 'merge' });
    this.refreshData();
  }

  onFilterChange(event: { value: SelectItem }): void {
    this.currentFilter = event?.value?.value || null;

    this.router.navigate([], {
      queryParams: { filter: this.currentFilter },
      queryParamsHandling: 'merge'
    });

    this.refreshData();
  }

  onSortChange(event: { value: SelectItem }): void {
    const [category, order] = event?.value?.value.split('-') || [];
    this.currentSort = order;
    this.currentSortCategory = category;

    this.router.navigate([], {
      queryParams: {
        sort: this.currentSort || null,
        sortCategory: this.currentSortCategory || null
      },
      queryParamsHandling: 'merge'
    });

    this.refreshData();
  }

  onBudgtChange(event: SliderSlideEndEvent): void {
    if (event.values !== undefined) {
      this.budgetRange = event.values;

      this.router.navigate([], {
        queryParams: {
          minBudget: this.budgetRange[0],
          maxBudget: this.budgetRange[1]
        },
        queryParamsHandling: 'merge'
      });
    }

    this.refreshData();
  }

  onDateChange(date: Date): void {
    if (date && this.dateRange) {
      this.router.navigate([], {
        queryParams: {
          startDate: this.dateRange[0]?.toISOString().split('T')[0],
          endDate: this.dateRange[1] ? this.dateRange[1].toISOString().split('T')[0] : null
        },
        queryParamsHandling: 'merge'
      });

      this.refreshData();
    }
  }

  copyToClipboard(pathUrl: string): void {
    const fullUrl = new URL(pathUrl, window.location.origin).href;
    this.clipboard.copy(fullUrl);
    this.messageService.add({
      severity: 'success',
      summary: this.translate.instant('request.copied')
    });
  }

  clearAdvancedFilters(): void {
    this.budgetRange = [0, 10000];
    this.dateRange = null;
    this.searchQuery = '';

    this.router.navigate([], {
      queryParams: {
        search: null,
        minBudget: null,
        maxBudget: null,
        startDate: null,
        endDate: null,
        filter: null,
        sort: null,
        sortCategory: null
      },
      queryParamsHandling: 'merge'
    });

    this.budgetRange = [0, 10000];
    this.dateRange = null;
    this.searchQuery = '';
    this.currentFilter = '';
    this.currentSort = '';
    this.currentSortCategory = '';

    this.selectedFilterOption = null
    this.selectedSortOption = null

    this.refreshData();
  }

  applyAdvancedFilters(): void {
    const queryParams: any = {
      minBudget: this.budgetRange[0],
      maxBudget: this.budgetRange[1]
    };

    if (this.dateRange && this.dateRange.length >= 1 && this.dateRange[0]) {
      queryParams.startDate = this.dateRange[0].toISOString().split('T')[0];

      if (this.dateRange.length === 2 && this.dateRange[1]) {
        queryParams.endDate = this.dateRange[1].toISOString().split('T')[0];
      } else {
        queryParams.endDate = null;
      }
    } else {
      queryParams.startDate = null;
      queryParams.endDate = null;
    }

    if (this.searchQuery) {
      queryParams.search = this.searchQuery;
    }

    if (this.currentFilter) {
      queryParams.filter = this.currentFilter;
    }

    if (this.currentSort) {
      queryParams.sort = this.currentSort;
    }

    if (this.currentSortCategory) {
      queryParams.sortCategory = this.currentSortCategory
    }

    this.router.navigate([], {
      queryParams: queryParams,
      queryParamsHandling: 'merge'
    });

    this.refreshData();
  }

  private translateFilament(id: number): string {
    const key = FilamentModel.filamentMap[id];
    return key ? this.translate.instant(`materials.${key}`) : `Unknown Filament (${id})`;
  }

  private translateColor(id: number): string {
    const key = ColorModel.colorMap[id];
    return key ? this.translate.instant(`colors.${key}`) : `Unknown Color (${id})`;
  }
}