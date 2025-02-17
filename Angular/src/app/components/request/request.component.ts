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
  searchQuery: string = ''; // Add this property

  get filteredRequests(): RequestModel[] {
    return this.activeTab === 'all'
      ? this.requests.filter(r =>
          r.name.toLowerCase().includes(this.searchQuery.toLowerCase())
        )
      : this.myRequests.filter(r =>
          r.name.toLowerCase().includes(this.searchQuery.toLowerCase())
        );
  }

  constructor(private requestService: RequestService, private router: Router) {}

  ngOnInit(): void {
    this.requestService.getAllRequests().subscribe((requests: RequestModel[]) => {
      this.requests = requests;
    });

    this.requestService.getMyRequests().subscribe((requests: RequestModel[]) => {
      this.myRequests = requests;
    });
  }

  expandAll(): void {
    this.expandedRows = this.filteredRequests.reduce((acc: { [key: number]: boolean }, request: RequestModel) => {
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
      this.requests = this.requests.filter(r => r.id !== this.requestToDelete?.id);
      this.requestToDelete = null;
    }
    this.deleteDialogVisible = false;
  }
}

