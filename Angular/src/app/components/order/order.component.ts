import { Component, inject } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { ImportsModule } from '../../../imports';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule, ValidationErrors, AbstractControl } from '@angular/forms';
import { DropdownModule } from 'primeng/dropdown';
import { MenuItem } from 'primeng/api';
import { StlModelViewerModule } from 'angular-stl-model-viewer';
import { MessageService } from 'primeng/api';
import { TranslatePipe, TranslateService } from '@ngx-translate/core';
import { Router, RouterLink } from '@angular/router';

import { OrderModel } from '../../models/order.model';
import { OrderStatusModel } from '../../models/order-status.model';
import { OrderService } from '../../services/order.service';
import { OrderStatusService } from '../../services/order-status.service';
import { ApiResponseModel } from '../../models/api-response.model';
import { AuthService } from '../../services/authentication.service';
import { ImageAttachmentModel } from '../../models/image-attachment.model';
import { ReviewModel } from '../../models/review.model';
import { ReviewFormComponent } from '../review-form/review-form.component';

interface StatusChoice {
  name: string;
  value: string;
}

@Component({
  selector: 'app-orders',
  imports: [ImportsModule, DropdownModule, ReactiveFormsModule, StlModelViewerModule, TranslatePipe, RouterLink, ReviewFormComponent],
  templateUrl: './order.component.html',
  styleUrl: './order.component.css'
})
export class OrderComponent {
  route: ActivatedRoute = inject(ActivatedRoute);
  orderService: OrderService = inject(OrderService);
  orderStatusService: OrderStatusService = inject(OrderStatusService);
  private readonly auth = inject(AuthService)
  messageService: MessageService = inject(MessageService);
  translate: TranslateService = inject(TranslateService);
  router : Router = inject(Router);

  order: OrderModel | null = null;
  currentStatus: OrderStatusModel | null = null;
  orderName: string = '';
  statusTranslations: { [key: string]: string } = {
    'Accepted': 'Accepted',
    'Printing': 'Printing',
    'Printed': 'Printed',
    'Shipped': 'Shipped',
    'Arrived': 'Arrived',
    'Cancelled': 'Cancelled'
  }
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
  availableStatuses: StatusChoice[] = []
  editMenuItems: MenuItem[] = [
    {
      label: 'Edit',
      icon: 'pi pi-pencil',
      command: () => {
        this.setStatusForm();
      }
    },
    {
      label: 'Delete',
      icon: 'pi pi-trash',
      command: () => {
        this.deleteStatusDialogVisible = true;
      }
    }
  ]
  errors_type: { [key: string]: string } = {}
  statusActions: MenuItem[] = [];
  AcceptedStatus: OrderStatusModel[] = [];
  PrintingStatus: OrderStatusModel[] = [];
  PrintedStatus: OrderStatusModel[] = [];
  ShippedStatus: OrderStatusModel[] = [];
  ArrivedStatus: OrderStatusModel[] = [];
  CancelledStatus: OrderStatusModel[] = [];
  canCancel: boolean = false;
  canArrive: boolean = false;
  consumer: boolean = false;
  formVisible: boolean = false;
  deleteStatusDialogVisible: boolean = false;
  isEdit: boolean = false;
  orderStatusForm: FormGroup;
  imageUrl: string = '';
  currentlySelectedOrderStatusId: number = -1
  tab : string = 'status';
  constructor(private fb: FormBuilder) {
    if (this.router.routerState.snapshot.root.queryParams["tab"] == 'status') {
      this.tab = 'status';
    }
    else if (this.router.routerState.snapshot.root.queryParams["tab"] == 'review') {
      this.tab = 'review';
    }
    else {
      this.tab = 'status';
    }

    this.translate.onLangChange.subscribe(() => {
      this.translateRefresh();
    });
    this.translateRefresh();

    this.refreshOrder();

    this.orderStatusForm = this.fb.group({
      statusName: ['', [Validators.required, this.statusNameValidator.bind(this)]],
      comment: ['', [Validators.minLength(5), Validators.maxLength(200)]],
      image: [null, this.imageValidator.bind(this)]
    });
  }

  imageValidator(control: AbstractControl): ValidationErrors | null {
    const file = control.value;
    if (file) {
      const validImageTypes = ['image/jpeg', 'image/png', 'image/gif'];
      if (!validImageTypes.includes(file.type)) {
        return { invalidFileType: 'Only image files are allowed' };
      }
    }
    return null;
  }

  statusNameValidator(control: AbstractControl): ValidationErrors | null {
    const statusName = control.value;
    if (!statusName) {
      return { statusNameError: 'Status is required' };
    }
    if (this.order?.availableStatus.includes(statusName)) {
      return null;
    } else {
      return { statusNameError: 'Invalid status' };
    }
  }

  setStatusTab(): void {
    this.router.navigate([`/orders/view/${Number(this.route.snapshot.params['id'])}`], { queryParams: { tab: 'status' } });
  }

  setReviewTab(): void {
    this.router.navigate([`/orders/view/${Number(this.route.snapshot.params['id'])}`], { queryParams: { tab: 'review' } });
  }

  translateRefresh() {
    this.errors_type = this.translate.instant(['global.errors'])['global.errors'];

    this.editMenuItems[0].label = this.translate.instant('global.edit_button');
    this.editMenuItems[1].label = this.translate.instant('global.delete_button');

    const message = this.translate.instant(['order.order_status.empty_comments.Accepted', 'order.order_status.empty_comments.Printing', 'order.order_status.empty_comments.Printed', 'order.order_status.empty_comments.Shipped', 'order.order_status.empty_comments.Arrived', 'order.order_status.empty_comments.Cancelled'])
    this.statusDefaultCommentRef['Accepted'] = message['order.order_status.empty_comments.Accepted'];
    this.statusDefaultCommentRef['Printing'] = message['order.order_status.empty_comments.Printing'];
    this.statusDefaultCommentRef['Printed'] = message['order.order_status.empty_comments.Printed'];
    this.statusDefaultCommentRef['Shipped'] = message['order.order_status.empty_comments.Shipped'];
    this.statusDefaultCommentRef['Arrived'] = message['order.order_status.empty_comments.Arrived'];
    this.statusDefaultCommentRef['Cancelled'] = message['order.order_status.empty_comments.Cancelled'];

    const statuses = this.translate.instant(['status.Accepted', 'status.Printing', 'status.Printed', 'status.Shipped', 'status.Arrived', 'status.Cancelled']);
    this.statusTranslations['Accepted'] = statuses['status.Accepted'];
    this.statusTranslations['Printing'] = statuses['status.Printing'];
    this.statusTranslations['Printed'] = statuses['status.Printed'];
    this.statusTranslations['Shipped'] = statuses['status.Shipped'];
    this.statusTranslations['Arrived'] = statuses['status.Arrived'];
    this.statusTranslations['Cancelled'] = statuses['status.Cancelled'];

    this.refreshStatusActions();
    this.refreshAvailableStatuses();
  }

  refreshOrder(): void {
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
    this.orderService.getOrder(orderId).subscribe((response: ApiResponseModel | OrderModel) => {
      if (response instanceof OrderModel) {
        this.order = response;
        if (this.order) {
          this.currentStatus = this.order.orderStatus[this.order.orderStatus.length - 1];
          if (this.order.availableStatus.includes('Cancelled')) {
            this.canCancel = true;
          }
          if (this.order.availableStatus.includes('Arrived')) {
            this.canArrive = true;
          }
          if (this.order?.offer?.request?.user?.id == this.auth.currentUser?.id) {
            this.consumer = true;
          }
          for (let status of this.order.orderStatus) {
            this.sortStatus(status);
          }
          this.refreshStatusActions();
          this.refreshAvailableStatuses();
        }
      } else {
        this.router.navigate(['/orders']);
      }

    });
  }

  refreshStatusActions(): void {
    this.statusActions = [];
    if (this.order?.availableStatus) {
      for (let status of this.order.availableStatus) {
        switch (status) {
          case 'Accepted':
            this.statusActions.push({
              label: this.statusTranslations['Accepted'],
              icon: 'pi pi-play',
              command: () => {
                this.ShowOrderStatusForm();
                this.orderStatusForm.patchValue({ statusName: 'Accepted' });
              }
            });
            break;
          case 'Printing':
            this.statusActions.push({
              label: this.statusTranslations['Printing'],
              icon: 'pi pi-print',
              command: () => {
                this.ShowOrderStatusForm();
                this.orderStatusForm.patchValue({ statusName: 'Printing' });
              }
            });
            break;
          case 'Printed':
            this.statusActions.push({
              label: this.statusTranslations['Printed'],
              icon: 'pi pi-check-circle',
              command: () => {
                this.ShowOrderStatusForm();
                this.orderStatusForm.patchValue({ statusName: 'Printed' });
              }
            });
            break;
          case 'Shipped':
            this.statusActions.push({
              label: this.statusTranslations['Shipped'],
              icon: 'pi pi-send',
              command: () => {
                this.ShowOrderStatusForm();
                this.orderStatusForm.patchValue({ statusName: 'Shipped' });
              }
            });
            break;
          case 'Arrived':
            this.statusActions.push({
              label: this.statusTranslations['Arrived'],
              icon: 'pi pi-home',
              command: () => {
                this.ShowOrderStatusForm();
                this.orderStatusForm.patchValue({ statusName: 'Arrived' });
              }
            });
            break;
          case 'Cancelled':
            this.statusActions.push({
              label: this.statusTranslations['Cancelled'],
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

  refreshAvailableStatuses(): void {
    this.availableStatuses = [];
    this.order?.availableStatus.forEach((status: string) => {
      this.availableStatuses.push({ name: this.statusTranslations[status], value: status });
    });
  }

  onFileSelect(event: any) {
    const file = event.files[0];
    this.imageUrl = file["objectURL"].changingThisBreaksApplicationSecurity;
    this.orderStatusForm.patchValue({ image: file });
  }

  ShowOrderStatusForm() : void {
    this.clearStatusForm();
    this.formVisible = true;
  }

  onStatusSubmit() : void {
    if (this.orderStatusForm.valid){

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
        this.orderStatusService.updateOrderStatus(this.currentlySelectedOrderStatusId, orderStatusData).subscribe((response: ApiResponseModel | OrderStatusModel) => {
          if (response instanceof OrderStatusModel) {
            this.refreshOrder();
            this.clearStatusForm();
            this.formVisible = false;
            this.isEdit = false;
            this.messageService.add({
              severity: 'success',
              summary: this.errors_type["summary_success"],
              detail: this.errors_type["updated_success"]
            });
          }else {
            this.messageService.add({
              severity: 'error',
              summary: this.errors_type["summary_error"],
              detail: this.errors_type["updated_error"]
            });
          }
        });
      }else{
        this.orderStatusService.createOrderStatus(orderStatusData).subscribe((response : ApiResponseModel | OrderStatusModel) => {
          if (response instanceof OrderStatusModel) {
            this.refreshOrder();
            this.clearStatusForm();
            this.formVisible = false;
            this.messageService.add({
              severity: 'success',
              summary: this.errors_type["summary_success"],
              detail: this.errors_type["created_success"]
            });
          }else{
            this.messageService.add({
              severity: 'error',
              summary: this.errors_type["summary_error"],
              detail: this.errors_type["created_error"]
            });
          }
        });
      }
    }
  }

  sortStatus(status: OrderStatusModel): void {
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

  clearStatusForm() : void {
    this.orderStatusForm.reset();
    this.isEdit = false;
    this.imageUrl = '';
  }

  setStatusForm() : void {
    this.orderStatusService.getOrderStatus(this.currentlySelectedOrderStatusId).subscribe((response : ApiResponseModel | OrderStatusModel) => {
      if (response instanceof OrderStatusModel) {
        const orderStatus = response;
        this.orderStatusForm.patchValue({ statusName: orderStatus.statusName });
        this.orderStatusForm.patchValue({ comment: orderStatus.comment });
        this.imageUrl = orderStatus.imageUrl;
        this.isEdit = true;
        this.formVisible = true;
      }
    });
  }

  DeleteOrderStatus(): void {
    this.orderStatusService.deleteOrderStatus(this.currentlySelectedOrderStatusId).subscribe((response: ApiResponseModel | OrderStatusModel) => {
      
      if (response instanceof OrderStatusModel) {
        this.refreshOrder();
        this.deleteStatusDialogVisible = false;
        this.messageService.add({
          severity: 'success',
          summary: this.errors_type["summary_success"],
          detail: this.errors_type["deleted_success"]
        });
      }else {
        this.messageService.add({
          severity: 'error',
          summary: this.errors_type["summary_error"],
          detail: this.errors_type["deleted_error"]
        });
        this.clearStatusForm();
      }

      
    });
  }

  setSelectedOrderStatus(orderStatusId: number): void {
    this.currentlySelectedOrderStatusId = orderStatusId;
  }
}
