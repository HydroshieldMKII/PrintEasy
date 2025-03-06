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
  selectedFilterOption: SelectItem | null = null;
  selectedSortOption: SelectItem | null = null;
  filterOptions: SelectItemGroup[] = []
  sortOptions: SelectItem[] = []
  showAdvancedFilters: boolean = false;

  constructor() {
    this.translate.onLangChange.subscribe(() => {
      this.translateRefresh();
    });
    this.translateRefresh();

    this.searchQuery = this.router.routerState.snapshot.root.queryParams["search"];
    this.selectedFilterOption = this.filterOptions
      .flatMap(group => group.items)
      .find(item => item.value == this.router.routerState.snapshot.root.queryParams["filter"]) ?? null;
    this.selectedSortOption = this.sortOptions.find(item => item.value == this.router.routerState.snapshot.root.queryParams["sort"]) ?? null;
    this.tab = this.router.routerState.snapshot.root.queryParams["tab"] ?? 'commands';

    if (this.selectedFilterOption || this.selectedSortOption) {
      this.showAdvancedFilters = true;
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
    if (this.selectedFilterOption) {
      params['filter'] = this.selectedFilterOption.value.toString();
    }
    if (this.selectedSortOption) {
      params['sort'] = this.selectedSortOption.value.toString();
    }
    if (this.searchQuery) {
      params['search'] = this.searchQuery;
    }
    this.router.navigate(['/orders'], { queryParams: params });
    if (this.tab == 'contracts') {
      this.getMakeOrders(params);
    }
    else {
      this.getMyOrders(params);
    }

  }

  openContracts() {
    this.tab = 'contracts';
    this.updateUrl();
  }

  openCommands() {
    this.tab = 'commands';
    this.updateUrl();
  }

}

