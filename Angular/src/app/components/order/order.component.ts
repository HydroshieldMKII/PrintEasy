import { Component, inject } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { ImportsModule } from '../../../imports';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule, ValidationErrors, AbstractControl } from '@angular/forms';
import { DropdownModule } from 'primeng/dropdown';
import { MenuItem } from 'primeng/api';
import { StlModelViewerModule } from 'angular-stl-model-viewer';
import { MessageService } from 'primeng/api';
import { TranslatePipe, TranslateService } from '@ngx-translate/core';

import { OrderModel } from '../../models/order.model';
import { OrderStatusModel } from '../../models/order-status.model';
import { OrderService } from '../../services/order.service';
import { OrderStatusService } from '../../services/order-status.service';
import { ApiResponseModel } from '../../models/api-response.model';
import { AuthService } from '../../services/authentication.service';
import { ReviewService } from '../../services/review.service';
import { ImageAttachmentModel } from '../../models/image-attachment.model';

interface StatusChoice {
  name: string;
  value: string;
}

@Component({
  selector: 'app-orders',
  imports: [ImportsModule, DropdownModule, ReactiveFormsModule, StlModelViewerModule, TranslatePipe],
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
  translate: TranslateService = inject(TranslateService);

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
  reviewImageUrls: ImageAttachmentModel[] = [];
  canCancel: boolean = false;
  canArrive: boolean = false;
  consumer: boolean = false;
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
    this.getStatusTranslations();
    this.getStatusDefaultMessages();
    this.getEditMenuWithTranslations();
    this.getTranslatedErrors();

    this.refreshOrder();

    this.translate.onLangChange.subscribe(() => {
      this.getStatusTranslations();
      this.getStatusDefaultMessages();
      this.getEditMenuWithTranslations();
      this.getTranslatedErrors();
    });

    this.orderStatusForm = this.fb.group({
      statusName: ['', [Validators.required, this.statusNameValidator.bind(this)]],
      comment: ['', [Validators.minLength(5), Validators.maxLength(200)]],
      image: [null, this.imageValidator.bind(this)]
    });

    this.reviewForm = this.fb.group({
      title: ['', [Validators.required, Validators.minLength(5), Validators.maxLength(30)]],
      rating: [null, [Validators.min(0), Validators.max(5)]],
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
    } else {
      return { statusNameError: 'Invalid status' };
    }
  }

  getStatusTranslations(): void {
    const results = this.translate.instant(['status.Accepted', 'status.Printing', 'status.Printed', 'status.Shipped', 'status.Arrived', 'status.Cancelled']);
    this.statusTranslations['Accepted'] = results['status.Accepted'];
    this.statusTranslations['Printing'] = results['status.Printing'];
    this.statusTranslations['Printed'] = results['status.Printed'];
    this.statusTranslations['Shipped'] = results['status.Shipped'];
    this.statusTranslations['Arrived'] = results['status.Arrived'];
    this.statusTranslations['Cancelled'] = results['status.Cancelled'];
  }

  getTranslatedErrors(): void {
    const results = this.translate.instant(['global.errors']);
    this.errors_type = results['global.errors'];
  }

  getStatusDefaultMessages(): void {
    const results = this.translate.instant(['order.order_status.empty_comments.Accepted', 'order.order_status.empty_comments.Printing', 'order.order_status.empty_comments.Printed', 'order.order_status.empty_comments.Shipped', 'order.order_status.empty_comments.Arrived', 'order.order_status.empty_comments.Cancelled'])
    this.statusDefaultCommentRef['Accepted'] = results['order.order_status.empty_comments.Accepted'];
    this.statusDefaultCommentRef['Printing'] = results['order.order_status.empty_comments.Printing'];
    this.statusDefaultCommentRef['Printed'] = results['order.order_status.empty_comments.Printed'];
    this.statusDefaultCommentRef['Shipped'] = results['order.order_status.empty_comments.Shipped'];
    this.statusDefaultCommentRef['Arrived'] = results['order.order_status.empty_comments.Arrived'];
    this.statusDefaultCommentRef['Cancelled'] = results['order.order_status.empty_comments.Cancelled'];
  }

  getEditMenuWithTranslations(): void {
    const results = this.translate.instant(['global.edit_button', 'global.delete_button'])
    this.editMenuItems[0].label = results['global.edit_button'];
    this.editMenuItems[1].label = results['global.delete_button'];
  }

  refreshOrder(): void {
    this.AcceptedStatus = [];
    this.PrintingStatus = [];
    this.PrintedStatus = [];
    this.ShippedStatus = [];
    this.ArrivedStatus = [];
    this.CancelledStatus = [];
    this.statusActions = [];
    this.reviewImageUrls = [];
    this.availableStatuses = [];
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
          console.log('Current status:', this.currentStatus);
          if (this.order.availableStatus.includes('Cancelled')) {
            this.canCancel = true;
          }
          if (this.order.availableStatus.includes('Arrived')) {
            this.canArrive = true;
          }
          if (this.order?.offer?.request?.user?.id == this.auth.currentUser?.id) {
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
          this.order.availableStatus.forEach((status: string) => {
            this.availableStatuses.push({ name: this.statusTranslations[status], value: status });
          });
          console.log('Available statuses:', this.availableStatuses);
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
    
    for (let file of files) {
      const reader = new FileReader();
      reader.onload = (e) => {
        this.reviewImageUrls.push(new ImageAttachmentModel(null, reader.result as string, file ));
      }
      reader.readAsDataURL(file);
    }
    console.log('Review images:', this.reviewImageUrls);
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
        this.orderStatusService.updateOrderStatus(this.currentlySelectedOrderStatusId, orderStatusData).subscribe((response: ApiResponseModel) => {
          console.log('Order status updated:', response);
          if (response.status == 200) {
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
        this.orderStatusService.createOrderStatus(orderStatusData).subscribe((response : ApiResponseModel) => {
          console.log('Order status created:', response);
          if (response.status == 201) {
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

  onReviewSubmit() : void {
    if (this.reviewForm.valid) {
      console.log('Review data form:', this.reviewForm.value);

      const reviewData = new FormData();
      reviewData.append('review[title]', this.reviewForm.value.title);
      reviewData.append('review[rating]', this.reviewForm.value.rating ?? 0);
      reviewData.append('review[description]', this.reviewForm.value.description);
      if (!this.isEditReview) {
        reviewData.append('review[order_id]', this.order?.id.toString() || '');
      }
      if (this.reviewImageUrls.length > 0) {
        this.reviewImageUrls.forEach((image : any) => {
          reviewData.append('review[images][]', image.signedId ?? image.file);
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
              summary: this.errors_type["summary_success"],
              detail: this.errors_type["updated_success"]
            });
          }else{
            this.messageService.add({
              severity: 'error',
              summary: this.errors_type["summary_error"],
              detail: this.errors_type["updated_error"]
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

  DeleteOrderStatus(): void {
    this.orderStatusService.deleteOrderStatus(this.currentlySelectedOrderStatusId).subscribe((response: ApiResponseModel) => {
      console.log('Order status deleted:', response);
      if (response.status != 200) {
        this.messageService.add({
          severity: 'error',
          summary: this.errors_type["summary_error"],
          detail: this.errors_type["deleted_error"]
        });
        this.clearReviewForm();
        return;
      }
      this.refreshOrder();
      this.deleteStatusDialogVisible = false;
      this.messageService.add({
        severity: 'success',
        summary: this.errors_type["summary_success"],
        detail: this.errors_type["deleted_success"]
      });
    });
  }

  DeleteReview() : void {
    this.reviewService.deleteReview(this.order?.review?.id || -1).subscribe((response : ApiResponseModel) => {
      console.log('Review deleted:', response);
      if (response.status != 200) {
        this.messageService.add({
          severity: 'error',
          summary: this.errors_type["summary_error"],
          detail: this.errors_type["deleted_error"]
        });
        return;
      }
      this.refreshOrder();
      this.deleteReviewDialogVisible = false;
      this.messageService.add({
        severity: 'success',
        summary: this.errors_type["summary_success"],
        detail: this.errors_type["deleted_success"]
      });
    });
  }

  deleteImage(url: string) : void {
    this.reviewImageUrls = this.reviewImageUrls.filter((image : ImageAttachmentModel) => image.url != url);
  }

  setSelectedOrderStatus(orderStatusId: number): void {
    this.currentlySelectedOrderStatusId = orderStatusId;
  }
}
