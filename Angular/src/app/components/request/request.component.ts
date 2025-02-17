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

  expandedRows: { [key: number]: boolean } = {};
  expandedRowsMyRequests: { [key: number]: boolean } = {};

  searchAllRequestQuery: string = '';
  searchMyRequestQuery: string = '';

  filteredAllRequests: RequestModel[] = [];
  filteredMyRequests: RequestModel[] = [];

  constructor(private requestService: RequestService, private router: Router) { }

  ngOnInit(): void {
    this.requestService.getAllRequests().subscribe((requests: RequestModel[]) => {
      console.log('Requests:', requests);
      this.requests = requests;
    });

    this.requestService.getMyRequests().subscribe((requests: RequestModel[]) => {
      console.log('My requests:', requests);
      this.myRequests = requests;
    });
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

    //remove greyed background
    const rows = document.querySelectorAll('td');
    rows.forEach(row => {
      row.style.backgroundColor = '';
    });
  }

  onRowExpand(event: any): void {
    this.expandedRows[event.data.id] = true;
    event.originalEvent.target.parentElement.parentElement.style.backgroundColor = 'lightgrey';
  }

  onRowCollapse(event: any): void {
    delete this.expandedRows[event.data.id];
    event.originalEvent.target.parentElement.parentElement.style.backgroundColor = '';
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
    const rows = document.querySelectorAll('td');
    rows.forEach(row => {
      row.style.backgroundColor = '';
    });
  }

  onRowExpandMyRequests(event: any): void {
    this.expandedRowsMyRequests[event.data.id] = true;

    //make row greyed
    event.originalEvent.target.parentElement.parentElement.style.backgroundColor = 'lightgrey';
  }

  onRowCollapseMyRequests(event: any): void {
    delete this.expandedRowsMyRequests[event.data.id];
    event.originalEvent.target.parentElement.parentElement.style.backgroundColor = '';
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
