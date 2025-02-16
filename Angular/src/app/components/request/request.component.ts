import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
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

  constructor(private requestService: RequestService, private router: Router) { }

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

    const rows = document.querySelectorAll('tr');
    rows.forEach((row) => {
      row.style.backgroundColor = '';
    });
  }

  onRowExpand(event: any): void {
    this.expandedRows[event.data.id] = true;

    //make row greyed
    event.originalEvent.target.parentElement.parentElement.style.backgroundColor = '#f9f9f9';
  }

  onRowCollapse(event: any): void {
    delete this.expandedRows[event.data.id];

    //remove greyed row
    event.originalEvent.target.parentElement.parentElement.style.backgroundColor = '';
  }

  goToRequest(requestId: number): void {
    // Navigate to the request details page
    this.router.navigate(['/request', requestId]);
  }
}
