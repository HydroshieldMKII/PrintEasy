import { Component } from '@angular/core';
import { SelectItem } from 'primeng/api';
import { Router, RouterLink } from '@angular/router';
import { RequestModel } from '../../models/request.model';
import { RequestService } from '../../services/request.service';
import { ImportsModule } from '../../../imports';

@Component({
  selector: 'app-request',
  imports: [ImportsModule, RouterLink],
  templateUrl: './request.component.html',
  styleUrls: ['./request.component.css']
})
export class RequestsComponent {
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

  filterOptions: SelectItem[] = [
    { label: 'Select a filter (Clear)', value: '' },
    { label: 'My printers', value: 'owned-printer' },
    { label: 'My country', value: 'country' },
  ];

  sortOptions: SelectItem[] = [
    { label: 'Select a filter (Clear)', value: '' },
    { label: 'Name (Asc)', value: 'name-asc' },
    { label: 'Name (Desc)', value: 'name-desc' },
    { label: 'Date (Asc)', value: 'date-asc' },
    { label: 'Date (Desc)', value: 'date-desc' },
    { label: 'Budget (Asc)', value: 'budget-asc' },
    { label: 'Budget (Desc)', value: 'budget-desc' },
    { label: 'Country (Asc)', value: 'country-asc' },
    { label: 'Country (Desc)', value: 'country-desc' }
  ];

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

  constructor(private requestService: RequestService, private router: Router) {
    const queryParams = this.router.parseUrl(this.router.url).queryParams;
    this.currentFilter = queryParams['filter'] || '';
    this.currentSort = queryParams['sort'] || '';
    this.currentSortCategory = queryParams['sortCategory'] || '';
    this.searchQuery = queryParams['search'] || '';

    // set tab
    this.activeTab = queryParams['tab'] || 'mine';
    this.router.navigate([], { queryParams: { tab: this.activeTab }, queryParamsHandling: 'merge' });

    // Fetch requests
    this.filter(this.activeTab);

    // Select the corresponding select sort and filter
    this.selectedFilterOption = this.filterOptions.find(option => option.value === this.currentFilter) || this.filterOptions[0];
    this.selectedSortOption = this.sortOptions.find(option => option.value === `${this.currentSortCategory}-${this.currentSort}`) || this.sortOptions[0];

    // Set serach
    this.searchQuery = queryParams['search'] || '';
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
}

