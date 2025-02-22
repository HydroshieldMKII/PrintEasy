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
  imports: [ImportsModule, DropdownModule, ReactiveFormsModule],
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
  statusDefaultCommentRef: { [key: string]: string } = {
    'Accepted': 'the order has been accepted.',
    'Printing': 'the order is being printed.',
    'Printed': 'the order has been printed.',
    'Shipped': 'the order has been shipped.',
    'Arrived': 'the order has arrived.',
    'Cancelled': 'the order has been cancelled.'
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
  statusActions: MenuItem[] = [];
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
    this.orderStatusForm = this.fb.group({
      statusName: ['', Validators.required],
      comment: [],
      image: [null]
    });
    
    this.refreshOrder();
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
          for (let status of this.order.availableStatus) {
            switch (status) {
              case 'Accepted':
                this.statusActions.push({
                  label: 'Accepted', 
                  icon: 'pi pi-play',
                  command: () => {
                    this.ShowOrderStatusForm();
                    this.orderStatusForm.patchValue({ statusName: 'Accepted' });
                  }
                });
                break;
              case 'Printing':
                this.statusActions.push({
                  label: 'Printing', 
                  icon: 'pi pi-print',
                  command: () => {
                    this.ShowOrderStatusForm();
                    this.orderStatusForm.patchValue({ statusName: 'Printing' });
                  }
                });
                break;
              case 'Printed':
                this.statusActions.push({
                  label: 'Printed', 
                  icon: 'pi pi-check-circle',
                  command: () => {
                    this.ShowOrderStatusForm();
                    this.orderStatusForm.patchValue({ statusName: 'Printed' });
                  }
                });
                break;
              case 'Shipped':
                this.statusActions.push({
                  label: 'Shipped', 
                  icon: 'pi pi-send',
                  command: () => {
                    this.ShowOrderStatusForm();
                    this.orderStatusForm.patchValue({ statusName: 'Shipped' });
                  }
                });
                break;
              case 'Arrived':
                this.statusActions.push({
                  label: 'Arrived', 
                  icon: 'pi pi-home',
                  command: () => {
                    this.ShowOrderStatusForm();
                    this.orderStatusForm.patchValue({ statusName: 'Arrived' });
                  }
                });
                break;
              case 'Cancelled':
                this.statusActions.push({
                  label: 'Cancelled', 
                  icon: 'pi pi-ban',
                  command: () => {
                    this.ShowOrderStatusForm();
                    this.orderStatusForm.patchValue({ statusName: 'Cancelled' });
                  }
                });
                break;
            }
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

  ShowOrderStatusForm() : void {
    this.clearForm();
    this.formVisible = true;
  }

  onSubmit() : void {
    if (this.orderStatusForm.valid){
      console.log('Order status data:', this.orderStatusForm.value);

      const orderStatusData = new FormData();
      orderStatusData.append('order_status[status_name]', this.orderStatusForm.value.statusName);
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
    this.isEdit = false;
    this.imageUrl = '';
  }

  setForm() : void {
    this.orderStatusService.getOrderStatus(this.currentlySelectedOrderStatusId).subscribe((response : ApiResponseModel) => {
      console.log('Order status:', response);
      if (response.status != 200) {
        return;
      }
      const orderStatus = response.data.order_status;
      this.orderStatusForm.patchValue({ statusName: orderStatus.statusName });
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
