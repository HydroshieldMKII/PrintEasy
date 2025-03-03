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

  // New filters
  budgetRange: number[] = [0, 10000];
  dateRange: Date[] | null = null;
  isAdvancedFiltering: boolean = false;

  currentLanguage: string = 'en';

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

    // Initialize budget range
    this.initBudgetRange();

    this.initializeSelectOptions();
    this.filter(this.activeTab);

    this.selectedFilterOption = this.filterOptions.find(option => option.value === this.currentFilter) || this.filterOptions[0];
    this.selectedSortOption = this.sortOptions.find(option => option.value === `${this.currentSortCategory}-${this.currentSort}`) || this.sortOptions[0];
  }

  // Initialize the budget range with correct values
  initBudgetRange(): void {
    // Default range
    this.budgetRange = [0, 10000];

    // Try to get stored range from query params
    const queryParams = this.router.parseUrl(this.router.url).queryParams;
    if (queryParams['minBudget'] && queryParams['maxBudget']) {
      this.budgetRange = [
        parseInt(queryParams['minBudget']),
        parseInt(queryParams['maxBudget'])
      ];
      this.isAdvancedFiltering = true;
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
    let filteredRequests = this.activeTab === 'mine' ? this.myRequests || [] : this.requests || [];

    // Apply the advanced filters if they're active
    if (this.isAdvancedFiltering) {
      filteredRequests = this.applyAdvancedFiltersToList(filteredRequests);
    }

    return filteredRequests;
  }

  applyAdvancedFiltersToList(requests: RequestModel[]): RequestModel[] {
    return requests.filter(request => {
      // Apply budget filter
      const budgetInRange = request.budget >= this.budgetRange[0] && request.budget <= this.budgetRange[1];

      // Apply date filter if set
      let dateInRange = true;
      if (this.dateRange && this.dateRange.length === 2 && this.dateRange[0] && this.dateRange[1]) {
        const requestDate = new Date(request.targetDate);
        const startDate = new Date(this.dateRange[0]);
        const endDate = new Date(this.dateRange[1]);

        // Set hours to 0 for proper comparison
        startDate.setHours(0, 0, 0, 0);
        endDate.setHours(23, 59, 59, 999);

        dateInRange = requestDate >= startDate && requestDate <= endDate;
      }

      return budgetInRange && dateInRange;
    });
  }

  filter(type: string): void {
    this.requestService
      .filter(this.currentFilter, this.currentSortCategory, this.currentSort, this.searchQuery, type)
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
    this.router.navigate([], { queryParams: { filter: this.currentFilter || null }, queryParamsHandling: 'merge' });

    this.filter('all');
    this.filter('mine');
  }

  onSortChange(event: { value: SelectItem }): void {
    console.log('Sort changed. New value:', event.value.value);
    const [category, order] = event.value.value.split('-');
    this.currentSort = order;
    this.currentSortCategory = category;
    this.router.navigate([], { queryParams: { sortCategory: this.currentSortCategory || null, sort: this.currentSort || null }, queryParamsHandling: 'merge' });

    this.filter('all');
    this.filter('mine');
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

  // Advanced filters methods
  clearAdvancedFilters(): void {
    this.budgetRange = [0, 10000];
    this.dateRange = null;
    this.isAdvancedFiltering = false;

    // Remove filter query parameters
    this.router.navigate([], {
      queryParams: {
        minBudget: null,
        maxBudget: null,
        startDate: null,
        endDate: null
      },
      queryParamsHandling: 'merge'
    });

    this.messageService.add({
      severity: 'info',
      summary: this.currentLanguage === 'fr' ? 'Filtres réinitialisés' : 'Filters cleared',
      detail: this.currentLanguage === 'fr' ? 'Tous les filtres avancés ont été réinitialisés' : 'All advanced filters have been reset'
    });
  }

  applyAdvancedFilters(): void {
    this.isAdvancedFiltering = true;

    // Save filter settings to query params for persistence
    const queryParams: any = {
      minBudget: this.budgetRange[0],
      maxBudget: this.budgetRange[1]
    };

    // Add date range if selected
    if (this.dateRange && this.dateRange.length === 2 && this.dateRange[0] && this.dateRange[1]) {
      queryParams.startDate = this.dateRange[0].toISOString().split('T')[0];
      queryParams.endDate = this.dateRange[1].toISOString().split('T')[0];
    }

    this.router.navigate([], {
      queryParams: queryParams,
      queryParamsHandling: 'merge'
    });

    this.messageService.add({
      severity: 'success',
      summary: this.currentLanguage === 'fr' ? 'Filtres appliqués' : 'Filters applied',
      detail: this.currentLanguage === 'fr'
        ? `Budget: ${this.budgetRange[0]}$ - ${this.budgetRange[1]}$${this.dateRange ? ', Dates sélectionnées' : ''}`
        : `Budget: ${this.budgetRange[0]}$ - ${this.budgetRange[1]}$${this.dateRange ? ', Date range selected' : ''}`
    });
  }
}