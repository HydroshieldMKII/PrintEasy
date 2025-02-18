import { Component, OnInit } from '@angular/core';
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

  filterOptions: any[] = [
    { label: 'Select a filter', value: '' },
    { label: 'My Requests', value: 'my' }
  ];

  sortOptions: any[] = [
    { label: 'Newest First', value: '' },
    { label: 'Oldest First', value: '' }
  ];

  get currentRequests(): RequestModel[] {
    if (this.activeTab === 'my') {
      return this.myRequests || [];
    }else{
      return this.requests || [];
    }
  }

  constructor(private requestService: RequestService, private router: Router) {}

  ngOnInit(): void {
    this.requestService.getPrinters().subscribe((isOwningPrinters: boolean) => {
      this.isOwningPrinter = isOwningPrinters;
      if (isOwningPrinters){
        this.requestService.getAllRequests().subscribe((requests: RequestModel[]) => {
          this.requests = requests;
        });
      }
    });

    this.requestService.getMyRequests().subscribe((requests: RequestModel[]) => {
      this.myRequests = requests;
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
  }
}

