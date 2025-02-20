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
  activeTab: string = 'all';
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

  get currentRequests(): RequestModel[] {
    console.debug('Current requests:', this.activeTab === 'my' ? this.myRequests : this.requests);
    console.debug('Active tab:', this.activeTab);
    console.debug('My requests:', this.myRequests);
    console.debug('Requests:', this.requests);
    return this.activeTab === 'my' ? this.myRequests || [] : this.requests || [];
  }


  constructor(private requestService: RequestService, private router: Router) {
    const queryParams = this.router.parseUrl(this.router.url).queryParams;
    this.currentFilter = queryParams['filter'] || '';
    this.currentSort = queryParams['sort'] || '';
    this.currentSortCategory = queryParams['sortCategory'] || '';
    this.searchQuery = queryParams['search'] || '';

    this.filter('all');
    this.filter('my');

    // Select the corresponding select sort and filter
    this.selectedFilterOption = this.filterOptions.find(option => option.value === this.currentFilter) || this.filterOptions[0];
    console.log('Selected filter option:', this.selectedFilterOption);

    this.selectedSortOption = this.sortOptions.find(option => option.value === `${this.currentSortCategory}-${this.currentSort}`) || this.sortOptions[0];
    console.log('Selected sort option:', this.selectedSortOption);

    this.searchQuery = queryParams['search'] || '';

    this.requestService.getPrintersUser().subscribe((printers: any) => {
      this.isOwningPrinter = printers?.length > 0;
    });
  }


  filter(type: string): void {
    this.requestService
      .filter(this.currentFilter, this.currentSortCategory, this.currentSort, this.searchQuery, type)
      .subscribe((requests: RequestModel[]) => {
        if (type === 'all') {
          this.requests = requests;
          console.log('Requests:', this.requests);
        } else if (type === 'my') {
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
    this.filter('my');
  }


  onFilterChange(event: { value: SelectItem }): void {
    console.log('Filter changed. New value:', event.value.value);
    this.currentFilter = event.value.value;
    this.router.navigate([], { queryParams: { filter: this.currentFilter || null }, queryParamsHandling: 'merge' });

    this.filter('all');
    this.filter('my');
  }

  onSortChange(event: { value: SelectItem }): void {
    console.log('Sort changed. New value:', event.value.value);
    const [category, order] = event.value.value.split('-');
    this.currentSort = order;
    this.currentSortCategory = category;
    this.router.navigate([], { queryParams: { sortCategory: this.currentSortCategory || null, sort: this.currentSort || null }, queryParamsHandling: 'merge' });

    this.filter('all');
    this.filter('my');
  }

}

