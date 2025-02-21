import { Component, inject } from '@angular/core';
import {ActivatedRoute} from '@angular/router';
import { ImportsModule } from '../../../imports';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule, ValidationErrors, AbstractControl } from '@angular/forms';
import { DropdownModule } from 'primeng/dropdown';
import { MenuItem } from 'primeng/api';

import { OrderModel } from '../../models/order.model';
import { OrderStatusModel } from '../../models/order-status.model';
import { OrderService } from '../../services/order.service';
import { OrderStatusService } from '../../services/order-status.service';
import { ApiResponseModel } from '../../models/api-response.model';
import { AuthService } from '../../services/authentication.service';


@Component({
  selector: 'app-orders',
  imports: [ImportsModule, DropdownModule],
  templateUrl: './order.component.html',
  styleUrl: './order.component.css'
})
export class OrderComponent {
  route: ActivatedRoute = inject(ActivatedRoute);
  orderService: OrderService = inject(OrderService);
  orderStatusService: OrderStatusService = inject(OrderStatusService);
  private readonly auth = inject(AuthService)

  order: OrderModel | null = null;
  currentStatus: OrderStatusModel | null = null;
  orderName: string = '';
  statusColorRef: { [key: string]: string } = {
    'Accepted': '#c5c5c5',
    'Printing': '#fa6bff',
    'Printed': '#ffb056',
    'Shipped': '#56c1ff',
    'Arrived': '#8fff62',
    'Cancelled': '#ff6262'
  }
  editMenuItems: MenuItem[] = [
    {
      label: 'Edit',
      icon: 'pi pi-pencil',
      command: () => {
        this.setForm();
      }
    },
    {
      label: 'Delete',
      icon: 'pi pi-trash',
      command: () => {
        this.DeleteOrderStatus();
      }
    }
  ]
  AcceptedStatus: OrderStatusModel[] = [];
  PrintingStatus: OrderStatusModel[] = [];
  PrintedStatus: OrderStatusModel[] = [];
  ShippedStatus: OrderStatusModel[] = [];
  ArrivedStatus: OrderStatusModel[] = [];
  CancelledStatus: OrderStatusModel[] = [];
  canCancel: boolean = false;
  canArrive: boolean = false;
  consumer : boolean = false;
  formVisible: boolean = false;
  isEdit: boolean = false;
  orderStatusForm: FormGroup;
  imageUrl: string = '';
  currentlySelectedOrderStatusId: number = -1

  constructor(private fb: FormBuilder) {
    this.refreshOrder();

    this.orderStatusForm = this.fb.group({
      status_name: ['', Validators.required],
      comment: [],
      image: [null]
    });
  }

  refreshOrder() : void {
    this.AcceptedStatus = [];
    this.PrintingStatus = [];
    this.PrintedStatus = [];
    this.ShippedStatus = [];
    this.ArrivedStatus = [];
    this.CancelledStatus = [];
    this.canCancel = false;
    this.canArrive = false;
    this.consumer = false;
    this.isEdit = false;

    const orderId = Number(this.route.snapshot.params['id']);
    this.orderService.getOrder(orderId).subscribe((response: ApiResponseModel) => {
      if (response.status === 200) {
        this.order = response.data.order;
        console.log('Order:', this.order);
        if (this.order) {
          this.currentStatus = this.order.orderStatus[this.order.orderStatus.length - 1];
          if (this.order.availableStatus.includes('Cancelled')) {
            this.canCancel = true;
          }
          if (this.order.availableStatus.includes('Arrived')) {
            this.canArrive = true;
          }
          if (this.order.offer.request.user.id == this.auth.currentUser?.id) {
            this.consumer = true;
          }
          for (let status of this.order.orderStatus) {
            this.sortStatus(status);
          }
        }
      }
      
    });
  }

  onFileSelect(event: any) {
    const file = event.files[0];
    this.imageUrl = file["objectURL"].changingThisBreaksApplicationSecurity;
    this.orderStatusForm.patchValue({ image: file });
    console.log('Image:', file);
  }

  Cancel() : void {
    const cancelStatusData = new FormData();

    cancelStatusData.append('order_status[status_name]', 'Cancelled');
    cancelStatusData.append('order_status[order_id]', this.order?.id.toString() || '');

    this.orderStatusService.createOrderStatus(cancelStatusData).subscribe((response : ApiResponseModel) => {
      console.log('Order status created:', response);
      if (response.status == 201) {
        this.refreshOrder();
      }
    });
  }

  Arrive() : void {
    const arriveStatusData = new FormData();

    arriveStatusData.append('order_status[status_name]', 'Arrived');
    arriveStatusData.append('order_status[order_id]', this.order?.id.toString() || '');

    this.orderStatusService.createOrderStatus(arriveStatusData).subscribe((response : ApiResponseModel) => {
      console.log('Order status created:', response.data.order_status);
      if (response.status == 201) {
        this.refreshOrder();
      }
    });
  }

  ShowOrderStatusForm() : void {
    this.formVisible = true;
  }

  onSubmit() : void {
    if (this.orderStatusForm.valid){
      console.log('Order status data:', this.orderStatusForm.value);

      const orderStatusData = new FormData();
      orderStatusData.append('order_status[status_name]', this.orderStatusForm.value.status_name);
      orderStatusData.append('order_status[order_id]', this.order?.id.toString() || '');
      if (this.orderStatusForm.value.comment != null) {
        orderStatusData.append('order_status[comment]', this.orderStatusForm.value.comment);
      }
      if (this.orderStatusForm.value.image != null) {
        orderStatusData.append('order_status[image]', this.orderStatusForm.value.image);
      }
      if (this.isEdit) {
        this.orderStatusService.updateOrderStatus(this.currentlySelectedOrderStatusId, orderStatusData).subscribe((response : ApiResponseModel) => {
          console.log('Order status updated:', response);
          if (response.status == 200) {
            this.refreshOrder();
            this.clearForm();
            this.formVisible = false;
            this.isEdit = false;
          }
        });
      }else{
        this.orderStatusService.createOrderStatus(orderStatusData).subscribe((response : ApiResponseModel) => {
          console.log('Order status created:', response);
          if (response.status == 201) {
            this.refreshOrder();
            this.clearForm();
            this.formVisible = false;
          }
        });
      }
    }
  }

  sortStatus(status : OrderStatusModel) : void {
    switch (status.statusName) {
      case 'Accepted':
        this.AcceptedStatus.push(status);
        break;
      case 'Printing':
        this.PrintingStatus.push(status);
        break;
      case 'Printed':
        this.PrintedStatus.push(status);
        break;
      case 'Shipped':
        this.ShippedStatus.push(status);
        break;
      case 'Arrived':
        this.ArrivedStatus.push(status);
        break;
      case 'Cancelled':
        this.CancelledStatus.push(status);
        break;
    }

  }

  clearForm() : void {
    this.orderStatusForm.reset();
    this.imageUrl = '';
  }

  setForm() : void {
    this.orderStatusService.getOrderStatus(this.currentlySelectedOrderStatusId).subscribe((response : ApiResponseModel) => {
      console.log('Order status:', response);
      if (response.status != 200) {
        return;
      }
      const orderStatus = response.data.order_status;
      this.orderStatusForm.patchValue({ status_name: orderStatus.status_name });
      this.orderStatusForm.patchValue({ comment: orderStatus.comment });
      this.imageUrl = orderStatus.imageUrl;
      this.isEdit = true;
      this.formVisible = true;
    });
  }

  DeleteOrderStatus() : void {
    this.orderStatusService.deleteOrderStatus(this.currentlySelectedOrderStatusId).subscribe((response : ApiResponseModel) => {
      console.log('Order status deleted:', response);
      if (response.status != 200) {
        return;
      }
      this.refreshOrder();
    });
  }

  setSelectedOrderStatus(orderStatusId : number) : void {
    this.currentlySelectedOrderStatusId = orderStatusId;
  }



}
