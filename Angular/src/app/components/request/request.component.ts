import { Component, OnInit } from '@angular/core';
import { RequestModel } from '../../models/request.model';
import { RequestService } from '../../services/request.service';
import { ImportsModule } from '../../../imports';

@Component({
  selector: 'app-request',
  imports: [ImportsModule],
  templateUrl: './request.component.html',
  styleUrls: ['./request.component.css']
})
export class RequestsComponent implements OnInit {
  activeTab: string = 'all'; // Controls the active tab
  requests: RequestModel[] = [];
  myRequests: RequestModel[] = [];
  expandedRows: { [key: number]: boolean } = {};

  constructor(private requestService: RequestService) { }

  ngOnInit(): void {
    this.requests = this.requestService.getAllRequests();
    this.myRequests = this.requests.filter(r => r.id === 1); // Example: Filter my requests
  }

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
}
