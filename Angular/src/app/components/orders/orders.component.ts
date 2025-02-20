import { Component, inject } from '@angular/core';
import { ImportsModule } from '../../../imports';
import { Router, RouterLink } from '@angular/router';

import { OrderModel } from '../../models/order.model';
import { OrderService } from '../../services/order.service';
import { ApiResponseModel } from '../../models/api-response.model';

@Component({
  selector: 'app-orders',
  imports: [ImportsModule, RouterLink],
  templateUrl: './orders.component.html',
  styleUrl: './orders.component.css'
})
export class OrdersComponent {
  orderService: OrderService = inject(OrderService);

  myOrders: OrderModel[] = [];
  makeOrders: OrderModel[] = [];

  constructor() {
    this.getMyOrders();
    this.getMakeOrders();
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
}

