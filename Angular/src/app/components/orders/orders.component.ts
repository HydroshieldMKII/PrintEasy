import { Component, inject } from '@angular/core';
import { ImportsModule } from '../../../imports';
import { Router, RouterLink } from '@angular/router';
import { SelectItem } from 'primeng/api';

import { OrderModel } from '../../models/order.model';
import { OrderService } from '../../services/order.service';
import { ApiResponseModel } from '../../models/api-response.model';
import { TranslatePipe, TranslateService } from '@ngx-translate/core';
import { SelectItemGroup } from 'primeng/api';
@Component({
  selector: 'app-orders',
  imports: [ImportsModule, RouterLink, TranslatePipe],
  templateUrl: './orders.component.html',
  styleUrl: './orders.component.css'
})
export class OrdersComponent {
  orderService: OrderService = inject(OrderService);
  router: Router = inject(Router);
  translate: TranslateService = inject(TranslateService);

  myOrders: OrderModel[] = [];
  makeOrders: OrderModel[] = [];
  reportData: Array<{}> = [];
  statusColorRef: { [key: string]: string } = {
    'Accepted': '#c5c5c5',
    'Printing': '#fa6bff',
    'Printed': '#ffb056',
    'Shipped': '#56c1ff',
    'Arrived': '#8fff62',
    'Cancelled': '#ff6262'
  }
  tab: string = 'commands';

  searchQuery: string | null = null;
  selectedFilterOption: SelectItem[] | null = null;
  selectedSortOption: SelectItem | null = null;
  selectedReportSortOption: SelectItem | null = null;
  reportStartDate: Date | null = null;
  reportEndDate: Date | null = null;
  filterOptions: SelectItemGroup[] = []
  sortOptions: SelectItem[] = []
  reportSortOptions: SelectItem[] = []
  showAdvancedFilters: boolean = false;

  constructor() {
    this.translate.onLangChange.subscribe(() => {
      this.translateRefresh();
    });
    this.translateRefresh();
    this.tab = this.router.routerState.snapshot.root.queryParams["tab"] ?? 'commands';
    if (this.tab == 'report') {
      this.selectedReportSortOption = this.reportSortOptions.find(item => item.value == this.router.routerState.snapshot.root.queryParams["sort"]) ?? null;
      this.reportStartDate = this.router.routerState.snapshot.root.queryParams["startDate"] ? new Date(this.router.routerState.snapshot.root.queryParams["startDate"]) : null;
      this.reportEndDate = this.router.routerState.snapshot.root.queryParams["endDate"] ? new Date(this.router.routerState.snapshot.root.queryParams["endDate"]) : null;
    } else {
      this.searchQuery = this.router.routerState.snapshot.root.queryParams["search"];
      const filters = this.router.routerState.snapshot.root.queryParams["filter"]?.split(';') ?? null;
      if (filters) {
        this.selectedFilterOption = this.filterOptions
          .flatMap(group => group.items)
          .filter(item => filters.includes(item.value));
      }
      this.selectedSortOption = this.sortOptions.find(item => item.value == this.router.routerState.snapshot.root.queryParams["sort"]) ?? null;

      if (this.selectedFilterOption || this.selectedSortOption) {
        this.showAdvancedFilters = true;
      }
    }
    
    this.updateUrl();
  }

  toggleAdvancedFilters(): void {
    this.showAdvancedFilters = !this.showAdvancedFilters;
  }

  translateRefresh() {
    this.filterOptions = [
      {
        label: 'Status',
        items: [
          { label: this.translate.instant('status.Accepted'), value: 'Accepted' },
          { label: this.translate.instant('status.Printing'), value: 'Printing' },
          { label: this.translate.instant('status.Printed'), value: 'Printed' },
          { label: this.translate.instant('status.Shipped'), value: 'Shipped' },
          { label: this.translate.instant('status.Arrived'), value: 'Arrived' },
          { label: this.translate.instant('status.Cancelled'), value: 'Cancelled' }
        ]
      },
      {
        label: this.translate.instant('order.review.tab'),
        items: [
          { label: this.translate.instant('orders.ssf.reviewed'), value: 'reviewed' },
          { label: this.translate.instant('orders.ssf.not_reviewed'), value: 'notReviewed' }
        ]
      }
    ]
    this.sortOptions = [
      { label: this.translate.instant('orders.ssf.name_asc'), value: 'name-asc' },
      { label: this.translate.instant('orders.ssf.name_desc'), value: 'name-desc' },
      { label: this.translate.instant('orders.ssf.price_asc'), value: 'price-asc' },
      { label: this.translate.instant('orders.ssf.price_desc'), value: 'price-desc' },
      { label: this.translate.instant('orders.ssf.date_asc'), value: 'date-asc' },
      { label: this.translate.instant('orders.ssf.date_desc'), value: 'date-desc' }
    ]

    this.reportSortOptions = [
      { label: this.translate.instant('orders.report.ssf.time_asc'), value: 'time-asc' },
      { label: this.translate.instant('orders.report.ssf.time_desc'), value: 'time-desc' },
      { label: this.translate.instant('orders.report.ssf.rating_asc'), value: 'rating-asc' },
      { label: this.translate.instant('orders.report.ssf.rating_desc'), value: 'rating-desc' },
      { label: this.translate.instant('orders.report.ssf.earnings_asc'), value: 'earnings-asc' },
      { label: this.translate.instant('orders.report.ssf.earnings_desc'), value: 'earnings-desc' }
    ]
  }

  getMyOrders(params: { [key: string]: string } = {}) {
    params['type'] = 'my';
    this.orderService.getOrders(params).subscribe((response: ApiResponseModel | OrderModel[]) => {
      if (Array.isArray(response)) {
        this.myOrders = response;
        console.log(this.myOrders);
      }
    });
  }

  getMakeOrders(params: { [key: string]: string } = {}) {
    params['type'] = 'printer';
    this.orderService.getOrders(params).subscribe((response: ApiResponseModel | OrderModel[]) => {
      if (Array.isArray(response)) {
        this.makeOrders = response;
        console.log(this.makeOrders);
      }
    });
  }

  getReport(params: { [key: string]: string } = {}) {
    params['type'] = 'report';
    this.orderService.getReport(params).subscribe((response: ApiResponseModel) => {
      this.reportData = response.data.printers;
      console.log(this.reportData);
    });
  }

  onSearch() {
    this.updateUrl();
  }

  onFilterChange(event: any) {
    this.updateUrl();
  }

  onSortChange(event: any) {
    this.updateUrl();
  }

  updateUrl() {
    let params: { [key: string]: string } = {};
    params['tab'] = this.tab;
    if (this.tab == 'report') {
      if (this.selectedReportSortOption){
        params["sort"] = this.selectedReportSortOption.value.toString()
      }
      if (this.reportStartDate) {
        const startDate = new Date(this.reportStartDate);
        params['startDate'] = `${startDate.getFullYear()}-${(startDate.getMonth() + 1).toString().padStart(2, '0')}-${startDate.getDate().toString().padStart(2, '0')}`;
        console.log(params['startDate']);
      }
      if (this.reportEndDate) {
        const endDate = new Date(this.reportEndDate);
        params['endDate'] = `${endDate.getFullYear()}-${(endDate.getMonth() + 1).toString().padStart(2, '0')}-${endDate.getDate().toString().padStart(2, '0')}`;
        console.log(params['endDate']);
      }
    } else {
      if (this.selectedFilterOption) {
        console.log(this.selectedFilterOption);
        let filter = "";
        for (let fil of this.selectedFilterOption) {
          filter += fil.value + ";";
        }
        if (filter){
          params['filter'] = filter;
        }
      }
      if (this.selectedSortOption) {
        params['sort'] = this.selectedSortOption.value.toString();
      }
      if (this.searchQuery) {
        params['search'] = this.searchQuery;
      }
    }
    

    this.router.navigate(['/orders'], { queryParams: params });
    if (this.tab == 'contracts') {
      this.getMakeOrders(params);
    }
    else if (this.tab == 'report') {
      this.getReport(params);
    }
    else {
      this.getMyOrders(params);
    }
  }

  clearAdvancedFilters() {
    this.selectedFilterOption = null;
    this.selectedSortOption = null;
    this.searchQuery = null;
    this.updateUrl();
  }

  openContracts() {
    this.tab = 'contracts';
    this.updateUrl();
  }

  openCommands() {
    this.tab = 'commands';
    this.updateUrl();
  }

  openReport() {
    this.tab = 'report';
    this.updateUrl();
  }

}

