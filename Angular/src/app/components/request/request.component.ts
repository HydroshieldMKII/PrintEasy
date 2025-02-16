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
  requests: RequestModel[] = [];
  myRequests: RequestModel[] = [];

  deleteDialogVisible: boolean = false;
  requestToDelete: RequestModel | null = null;

  // Separate expand tracking for both tables
  expandedRows: { [key: number]: boolean } = {};
  expandedRowsMyRequests: { [key: number]: boolean } = {};

  constructor(private requestService: RequestService, private router: Router) { }

  ngOnInit(): void {
    this.requests = this.requestService.getAllRequests();
    this.myRequests = this.requests.filter(r => r.id === 1); // Example: Filter my requests
  }

  // Expand/collapse for "All Requests"
  expandAll(): void {
    this.expandedRows = this.requests.reduce((acc: { [key: number]: boolean }, request: RequestModel) => {
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

  // Expand/collapse for "My Requests"
  expandAllMyRequests(): void {
    this.expandedRowsMyRequests = this.myRequests.reduce((acc: { [key: number]: boolean }, request: RequestModel) => {
      acc[request.id] = true;
      return acc;
    }, {});
  }

  collapseAllMyRequests(): void {
    this.expandedRowsMyRequests = {};
  }

  onRowExpandMyRequests(event: any): void {
    this.expandedRowsMyRequests[event.data.id] = true;
  }

  onRowCollapseMyRequests(event: any): void {
    delete this.expandedRowsMyRequests[event.data.id];
  }

  downloadRequest(requestId: number): void {
    console.log('Download request with ID:', requestId);
    // this.requestService.downloadRequest(requestId);
  }

  showDeleteDialog(request: RequestModel): void {
    this.requestToDelete = request;
    this.deleteDialogVisible = true;
  }

  confirmDelete(): void {
    if (this.requestToDelete !== null) {
      this.requests = this.requests.filter(r => r.id !== this.requestToDelete?.id);
      this.requestToDelete = null;
    }
    this.deleteDialogVisible = false;
  }
}
