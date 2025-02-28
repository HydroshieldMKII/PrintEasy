import { Component, inject } from '@angular/core';
import { ImportsModule } from '../../../imports';
import { Router, RouterLink } from '@angular/router';

import { OrderModel } from '../../models/order.model';
import { OrderService } from '../../services/order.service';
import { ApiResponseModel } from '../../models/api-response.model';
import { TranslatePipe, TranslateService } from '@ngx-translate/core';
@Component({
  selector: 'app-orders',
  imports: [ImportsModule, RouterLink, TranslatePipe],
  templateUrl: './orders.component.html',
  styleUrl: './orders.component.css'
})
export class OrdersComponent {
  orderService: OrderService = inject(OrderService);
  router : Router = inject(Router);

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
  tab : string = 'commands';

  constructor() {
    if (this.router.routerState.snapshot.root.queryParams["tab"] == 'commands') {
      this.tab = 'commands';
      this.getMyOrders();
    }
    else if (this.router.routerState.snapshot.root.queryParams["tab"] == 'contracts') {
      this.tab = 'contracts';
      this.getMakeOrders();
    }
    else {
      this.tab = 'commands';
      this.getMyOrders();
    }
  }

  getMyOrders() {
    this.orderService.getMyOrders().subscribe((response: ApiResponseModel) => {
      this.myOrders = response.data.orders;
      console.log(this.myOrders);
    });
  }

  getMakeOrders() {
    this.orderService.getMakeOrders().subscribe((response: ApiResponseModel) => {
      this.makeOrders = response.data.orders;
      console.log(this.makeOrders);
    });
  }

  openContracts() {
    this.router.navigate(['/orders'], { queryParams: { tab: 'contracts' } });
    if (this.makeOrders.length == 0){
      this.getMakeOrders();
    }
  }

  openCommands() {
    this.router.navigate(['/orders'], { queryParams: { tab: 'commands' } });
    if (this.myOrders.length == 0){
      this.getMyOrders();
    }
  }
}

