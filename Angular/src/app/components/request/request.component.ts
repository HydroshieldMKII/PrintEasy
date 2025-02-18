import { Component, OnInit } from '@angular/core';
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
export class RequestsComponent implements OnInit {
  activeTab: string = 'all';
  requests: RequestModel[] | null | undefined = undefined;
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

  filterOptions: any[] = [
    { label: 'Select a filter (Clear)', value: '' },
    { label: 'Recommended', value: 'owned-printer' },
    { label: 'In my country', value: 'country' },
  ];

  sortOptions: any[] = [
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
    return this.activeTab === 'my' ? this.myRequests || [] : this.requests || [];
  }
  

  constructor(private requestService: RequestService, private router: Router) {}

  ngOnInit(): void {
    this.requestService.getPrinters().subscribe((isOwningPrinters: boolean) => {
      this.isOwningPrinter = isOwningPrinters;
      if (isOwningPrinters){
        this.loadRequests('');
      }
    });
  
    this.loadMyRequests({'filter': this.currentFilter, 'sort': this.currentSort});
  }

  loadRequests(params: string): void {
    this.requestService.getMyRequests().subscribe((myRequests: RequestModel[]) => {
      this.myRequests = myRequests;
    });
  }

  loadMyRequests(params: { filter: string; sort: string }): void {
    this.requestService.getAllRequests().subscribe((requests: RequestModel[]) => {
      this.requests = requests;
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

  downloadRequest(requestId: number): void {
    console.log('Download request with ID:', requestId);
  }

  showDeleteDialog(request: RequestModel): void {
    this.requestToDelete = request;
    this.deleteDialogVisible = true;
  }

  confirmDelete(): void {
    if (this.requestToDelete !== null) {
      // this.requestService.deleteRequest(this.requestToDelete.id).subscribe(() => {
      //   this.requests = this.requests?.filter(r => r.id !== this.requestToDelete?.id);
      //   this.myRequests = this.myRequests?.filter(r => r.id !== this.requestToDelete?.id);
      // });
    }
    this.deleteDialogVisible = false;
  }

  onSearch(): void {
    console.log('Search query:', this.searchQuery);
    this.router.navigate([], { queryParams: { search: this.searchQuery }, queryParamsHandling: 'merge' });
  }
  
  onFilterChange(event: { value: SelectItem }): void {
    console.log('Filter changed. New value:', event);
    this.currentFilter = event.value.value;
    this.router.navigate([], { queryParams: { filter: this.currentFilter }, queryParamsHandling: 'merge' });
  }

  onSortChange(event: { value: SelectItem }): void {
    console.log('Sort changed. New value:', event.value.value);
    const [category, order] = event.value.value.split('-');
    this.currentSort = order;
    this.currentSortCategory = category;
    this.router.navigate([], { queryParams: { sortCategory: this.currentSortCategory,  sort: this.currentSort}, queryParamsHandling: 'merge' });

    //if params a parms is emprty remove it
    if (event.value.value === '') {
      this.router.navigate([], { queryParams: { sortCategory: null,  sort: null}, queryParamsHandling: 'merge' });
    }
  }
}

