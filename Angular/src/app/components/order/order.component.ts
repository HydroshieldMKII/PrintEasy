import { Component, inject } from '@angular/core';
import {ActivatedRoute} from '@angular/router';
import { ImportsModule } from '../../../imports';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule, ValidationErrors, AbstractControl } from '@angular/forms';
import { DropdownModule } from 'primeng/dropdown';
import { MenuItem } from 'primeng/api';
import { StlModelViewerModule } from 'angular-stl-model-viewer';
import { MessageService } from 'primeng/api';

import { OrderModel } from '../../models/order.model';
import { OrderStatusModel } from '../../models/order-status.model';
import { OrderService } from '../../services/order.service';
import { OrderStatusService } from '../../services/order-status.service';
import { ApiResponseModel } from '../../models/api-response.model';
import { AuthService } from '../../services/authentication.service';
import { ReviewService } from '../../services/review.service';

@Component({
  selector: 'app-orders',
  imports: [ImportsModule, DropdownModule, ReactiveFormsModule, StlModelViewerModule],
  templateUrl: './order.component.html',
  styleUrl: './order.component.css'
})
export class OrderComponent {
  route: ActivatedRoute = inject(ActivatedRoute);
  orderService: OrderService = inject(OrderService);
  orderStatusService: OrderStatusService = inject(OrderStatusService);
  private readonly auth = inject(AuthService)
  messageService: MessageService = inject(MessageService);
  reviewService: ReviewService = inject(ReviewService);

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
  statusActions: MenuItem[] = [];
  AcceptedStatus: OrderStatusModel[] = [];
  PrintingStatus: OrderStatusModel[] = [];
  PrintedStatus: OrderStatusModel[] = [];
  ShippedStatus: OrderStatusModel[] = [];
  ArrivedStatus: OrderStatusModel[] = [];
  CancelledStatus: OrderStatusModel[] = [];
  reviewImageUrls: string[] = [];
  canCancel: boolean = false;
  canArrive: boolean = false;
  consumer : boolean = false;
  formVisible: boolean = false;
  deleteStatusDialogVisible: boolean = false;
  deleteReviewDialogVisible: boolean = false;
  isEdit: boolean = false;
  isEditReview: boolean = false;
  orderStatusForm: FormGroup;
  reviewForm: FormGroup;
  imageUrl: string = '';
  currentlySelectedOrderStatusId: number = -1

  constructor(private fb: FormBuilder) {
    this.refreshOrder();

    this.orderStatusForm = this.fb.group({
      statusName: ['', [Validators.required, this.statusNameValidator.bind(this)]],
      comment: ['', [Validators.minLength(5), Validators.maxLength(200)]],
      image: [null, this.imageValidator.bind(this)]
    });

    this.reviewForm = this.fb.group({
      title: ['', [Validators.required, Validators.minLength(5), Validators.maxLength(50)]],
      rating: [1, [Validators.required, Validators.min(0), Validators.max(5)]],
      description: ['', [Validators.minLength(5), Validators.maxLength(200)]],
      images: [[]]
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
    }else{
      return { statusNameError: 'Invalid status' };
    }
  }

  refreshOrder() : void {
    this.AcceptedStatus = [];
    this.PrintingStatus = [];
    this.PrintedStatus = [];
    this.ShippedStatus = [];
    this.ArrivedStatus = [];
    this.CancelledStatus = [];
    this.statusActions = [];
    this.canCancel = false;
    this.canArrive = false;
    this.consumer = false;
    this.isEdit = false;
    this.isEditReview = false;

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
          }else{
            this.reviewForm.get('rating')?.disable();
            this.reviewForm.get('title')?.disable();
            this.reviewForm.get('description')?.disable();
          }
          for (let status of this.order.orderStatus) {
            this.sortStatus(status);
          }
          if (this.order.review){
            this.isEditReview = true;
            this.reviewImageUrls = this.order.review.imageUrls;
            this.reviewForm.patchValue({ title: this.order.review.title });
            this.reviewForm.patchValue({ rating: this.order.review.rating });
            this.reviewForm.patchValue({ description: this.order.review.description });
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
          console.log('Status actions:', this.statusActions);
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

  onReviewFileSelect(event: any) {
    const files = event.files;
    let formFiles = [];
    for (let file of files) {
      this.reviewImageUrls.push(file["objectURL"].changingThisBreaksApplicationSecurity);
      formFiles.push(file);
    }
    this.reviewForm.patchValue({ images: formFiles });
  }

  ShowOrderStatusForm() : void {
    this.clearStatusForm();
    this.formVisible = true;
  }

  onStatusSubmit() : void {
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
            this.clearStatusForm();
            this.formVisible = false;
            this.isEdit = false;
            this.messageService.add({
              severity: 'success',
              summary: 'Created',
              detail: 'Order status updated successfully'
            });
          }else {
            this.messageService.add({
              severity: 'error',
              summary: 'Error',
              detail: 'Failed to update order status'
            });
          }
        });
      }else{
        this.orderStatusService.createOrderStatus(orderStatusData).subscribe((response : ApiResponseModel) => {
          console.log('Order status created:', response);
          if (response.status == 201) {
            this.refreshOrder();
            this.clearStatusForm();
            this.formVisible = false;
            this.messageService.add({
              severity: 'success',
              summary: 'Created',
              detail: 'Order status created successfully'
            });
          }else{
            this.messageService.add({
              severity: 'error',
              summary: 'Error',
              detail: 'Failed to create order status'
            });
          }
        });
      }
    }
  }

  onReviewSubmit() : void {
    if (this.reviewForm.valid) {
      console.log('Review data form:', this.reviewForm.value);

      const reviewData = new FormData();
      reviewData.append('review[title]', this.reviewForm.value.title);
      reviewData.append('review[rating]', this.reviewForm.value.rating);
      reviewData.append('review[description]', this.reviewForm.value.description);
      if (!this.isEditReview) {
        reviewData.append('review[order_id]', this.order?.id.toString() || '');
      }
      if (this.reviewForm.value.images && this.reviewForm.value.images.length > 0) {
        this.reviewForm.value.images.forEach((image : any) => {
          reviewData.append('review[images][]', image);
        });
      }
      console.log('Review data:', reviewData);
      if (this.isEditReview) {
        this.reviewService.updateReview(this.order?.review?.id || -1, reviewData).subscribe((response : ApiResponseModel) => {
          console.log('Review updated:', response);
          if (response.status == 200) {
            this.clearReviewForm();
            this.refreshOrder();
            this.deleteReviewDialogVisible = false;
            this.messageService.add({
              severity: 'success',
              summary: 'Created',
              detail: 'Review updated successfully'
            });
          }else{
            this.messageService.add({
              severity: 'error',
              summary: 'Error',
              detail: 'Failed to update review'
            });
          }
        });
      }else{
        this.reviewService.createReview(reviewData).subscribe((response : ApiResponseModel) => {
          console.log('Review created:', response);
          if (response.status == 201) {
            this.clearReviewForm();
            this.refreshOrder();
            this.deleteReviewDialogVisible = false;
            this.messageService.add({
              severity: 'success',
              summary: 'Created',
              detail: 'Review created successfully'
            });
          }else{
            this.messageService.add({
              severity: 'error',
              summary: 'Error',
              detail: 'Failed to create review'
            });
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

  clearStatusForm() : void {
    this.orderStatusForm.reset();
    this.isEdit = false;
    this.imageUrl = '';
  }

  clearReviewForm() : void {
    this.reviewForm.reset();
    this.reviewImageUrls = [];
  }

  setStatusForm() : void {
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
        this.messageService.add({
          severity: 'error',
          summary: 'Error',
          detail: 'Failed to delete order status'
        });
        return;
      }
      this.refreshOrder();
      this.deleteStatusDialogVisible = false;
      this.messageService.add({
        severity: 'success',
        summary: 'Deleted',
        detail: 'Order status deleted successfully'
      });
    });
  }

  DeleteReview() : void {
    this.reviewService.deleteReview(this.order?.review?.id || -1).subscribe((response : ApiResponseModel) => {
      console.log('Review deleted:', response);
      if (response.status != 200) {
        this.messageService.add({
          severity: 'error',
          summary: 'Error',
          detail: 'Failed to delete review'
        });
        return;
      }
      this.refreshOrder();
      this.deleteReviewDialogVisible = false;
      this.messageService.add({
        severity: 'success',
        summary: 'Deleted',
        detail: 'Review deleted successfully'
      });
    });
  }

  setSelectedOrderStatus(orderStatusId : number) : void {
    this.currentlySelectedOrderStatusId = orderStatusId;
  }
}
