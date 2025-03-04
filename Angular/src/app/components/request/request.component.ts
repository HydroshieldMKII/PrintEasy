import { Component, OnInit } from '@angular/core';
import { SelectItem } from 'primeng/api';
import { Router, RouterLink } from '@angular/router';
import { RequestModel } from '../../models/request.model';
import { RequestService } from '../../services/request.service';
import { ImportsModule } from '../../../imports';
import { MessageService } from 'primeng/api';
import { Clipboard } from '@angular/cdk/clipboard';
import { TranslatePipe, TranslateService } from '@ngx-translate/core';

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
  dateRange: Date[] | null = null;

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
    private translateService: TranslateService
  ) {
    const queryParams = this.router.parseUrl(this.router.url).queryParams;
    this.currentFilter = queryParams['filter'] || '';
    this.currentSort = queryParams['sort'] || '';
    this.currentSortCategory = queryParams['sortCategory'] || '';
    this.searchQuery = queryParams['search'] || '';

    // set tab
    this.activeTab = queryParams['tab'] || 'mine';
    this.router.navigate([], { queryParams: { tab: this.activeTab }, queryParamsHandling: 'merge' });
  }

  ngOnInit(): void {
    this.currentLanguage = localStorage.getItem('language') || 'en';

    this.initBudgetRange();
    this.initDateRange();

    this.initializeSelectOptions();
    this.filter(this.activeTab);

    this.selectedFilterOption = this.filterOptions.find(option => option.value === this.currentFilter) || this.filterOptions[0];
    this.selectedSortOption = this.sortOptions.find(option => option.value === `${this.currentSortCategory}-${this.currentSort}`) || this.sortOptions[0];
  }

  initDateRange(): void {
    this.dateRange = null;

    const queryParams = this.router.parseUrl(this.router.url).queryParams;
    if (queryParams['startDate'] && queryParams['endDate']) {
      const startDate = new Date(queryParams['startDate']);
      const endDate = new Date(queryParams['endDate']);

      startDate.setUTCHours(12, 0, 0, 0);
      endDate.setUTCHours(12, 0, 0, 0);

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

  initializeSelectOptions(): void {
    if (this.currentLanguage === 'fr') {
      this.filterOptions = [
        { label: 'Aucun', value: '' },
        { label: 'Mes imprimantes', value: 'owned-printer' },
        { label: 'Mon pays', value: 'country' },
        { label: 'Acceptées', value: 'in-progress' }
      ];

      this.sortOptions = [
        { label: 'Aucun', value: '' },
        { label: 'Nom (Asc)', value: 'name-asc' },
        { label: 'Nom (Desc)', value: 'name-desc' },
        { label: 'Date (Asc)', value: 'date-asc' },
        { label: 'Date (Desc)', value: 'date-desc' },
        { label: 'Budget (Asc)', value: 'budget-asc' },
        { label: 'Budget (Desc)', value: 'budget-desc' },
        { label: 'Pays (Asc)', value: 'country-asc' },
        { label: 'Pays (Desc)', value: 'country-desc' }
      ];
    } else {
      this.filterOptions = [
        { label: 'None', value: '' },
        { label: 'My printers', value: 'owned-printer' },
        { label: 'My country', value: 'country' },
        { label: 'Accepted', value: 'in-progress' }
      ];

      this.sortOptions = [
        { label: 'None', value: '' },
        { label: 'Name (Asc)', value: 'name-asc' },
        { label: 'Name (Desc)', value: 'name-desc' },
        { label: 'Date (Asc)', value: 'date-asc' },
        { label: 'Date (Desc)', value: 'date-desc' },
        { label: 'Budget (Asc)', value: 'budget-asc' },
        { label: 'Budget (Desc)', value: 'budget-desc' },
        { label: 'Country (Asc)', value: 'country-asc' },
        { label: 'Country (Desc)', value: 'country-desc' }
      ];
    }
  }

  onTabChange(tab: string): void {
    console.log('Tab changed:', tab);
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
    const startDate = this.dateRange && this.dateRange.length > 0 ? this.dateRange[0] : null;
    const endDate = this.dateRange && this.dateRange.length > 1 ? this.dateRange[1] : null;

    this.requestService
      .filter(this.currentFilter, this.currentSortCategory, this.currentSort, this.searchQuery, this.budgetRange[0], this.budgetRange[1], startDate, endDate, type)
      .subscribe(([requests, isOwningPrinter]: [RequestModel[], boolean]) => {

        if (this.isOwningPrinter === null) {
          console.log('Is owning printer:', isOwningPrinter);
          this.isOwningPrinter = isOwningPrinter;
        }

        if (type === 'all') {
          this.requests = requests;
          console.log('Requests:', this.requests);
        } else if (type === 'mine') {
          this.myRequests = requests;
          console.log('My requests:', this.myRequests);
        } else {
          console.error('Invalid filter type:', type);
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
    console.log('Download request:', downloadUrl);
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
    console.log('Search query:', this.searchQuery);
    this.router.navigate([], { queryParams: { search: this.searchQuery || null }, queryParamsHandling: 'merge' });

    this.filter('all');
    this.filter('mine');
  }

  onFilterChange(event: { value: SelectItem }): void {
    console.log('Filter changed. New value:', event.value.value);
    this.currentFilter = event.value.value;
  }

  onSortChange(event: { value: SelectItem }): void {
    console.log('Sort changed. New value:', event.value.value);
    const [category, order] = event.value.value.split('-');
    this.currentSort = order;
    this.currentSortCategory = category;
  }

  copyToClipboard(text: string): void {
    const fullUrl = new URL(text, window.location.origin).href;
    console.log('Copied to clipboard:', fullUrl);
    this.clipboard.copy(fullUrl);
    this.messageService.add({
      severity: 'success',
      summary: this.currentLanguage === 'fr' ? 'Demande copiée dans le presse-papiers' : 'Copied request to clipboard'
    });
  }

  updateLanguage(newLanguage: string): void {
    this.currentLanguage = newLanguage;
    localStorage.setItem('language', newLanguage);
    this.initializeSelectOptions();

    this.selectedFilterOption = this.filterOptions.find(option => option.value === this.currentFilter) || this.filterOptions[0];
    this.selectedSortOption = this.sortOptions.find(option => option.value === `${this.currentSortCategory}-${this.currentSort}`) || this.sortOptions[0];
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
        endDate: null
      },
      queryParamsHandling: 'merge'
    });

    this.selectedFilterOption = this.filterOptions[0];
    this.selectedSortOption = this.sortOptions[0];

    this.filter('all');
    this.filter('mine');
  }

  applyAdvancedFilters(): void {

    //budget range
    const queryParams: any = {
      minBudget: this.budgetRange[0],
      maxBudget: this.budgetRange[1]
    };

    //date range
    if (this.dateRange && this.dateRange.length === 2 && this.dateRange[0] && this.dateRange[1]) {
      queryParams.startDate = this.dateRange[0].toISOString().split('T')[0];
      queryParams.endDate = this.dateRange[1].toISOString().split('T')[0];
    }

    this.router.navigate([], {
      queryParams: queryParams,
      queryParamsHandling: 'merge'
    });

    this.filter('all');
    this.filter('mine');
  }
}