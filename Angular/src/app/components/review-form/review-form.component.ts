import { Component, Input, inject, input } from '@angular/core';
import { ImportsModule } from '../../../imports';	
import { ReviewModel } from '../../models/review.model';
import { ReviewService } from '../../services/review.service';
import { TranslatePipe } from '@ngx-translate/core';
import { MessageService } from 'primeng/api';
import { ImageAttachmentModel } from '../../models/image-attachment.model';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule, ValidationErrors, AbstractControl } from '@angular/forms';
import { ApiResponseModel } from '../../models/api-response.model';
import { TranslateService } from '@ngx-translate/core';
import { AuthService } from '../../services/authentication.service';
import { SimpleChanges } from '@angular/core';

@Component({
  selector: 'app-review-form',
  imports: [ImportsModule, TranslatePipe, ReactiveFormsModule],
  templateUrl: './review-form.component.html',
  styleUrl: './review-form.component.css'
})
export class ReviewFormComponent {
  @Input() review!: ReviewModel | null;
  @Input() order_id!: number;
  @Input() consumer!: boolean;

  messageService: MessageService = inject(MessageService);
  reviewService: ReviewService = inject(ReviewService);
  translate: TranslateService = inject(TranslateService);
  auth: AuthService = inject(AuthService);

  deleteReviewDialogVisible: boolean = false;
  isEditReview: boolean = false;
  reviewForm: FormGroup;
  reviewImageUrls: ImageAttachmentModel[] = [];
  errors_type: { [key: string]: string } = {}

  constructor(private fb: FormBuilder) {
    this.reviewForm = this.fb.group({
      title: ['', [Validators.required, Validators.minLength(5), Validators.maxLength(30)]],
      rating: [null, [Validators.min(0), Validators.max(5)]],
      description: ['', [Validators.minLength(5), Validators.maxLength(200)]],
      images: [[]]
    });

    this.translate.onLangChange.subscribe(() => {
      this.translateRefresh();
    });
    this.translateRefresh();
  }

  ngOnChanges(changes: SimpleChanges): void {
    if (changes['review'] && this.review) {
      this.isEditReview = true;
      this.reviewForm.patchValue({
        title: this.review.title,
        rating: this.review.rating,
        description: this.review.description
      });
      this.reviewImageUrls = this.review.imageUrls;

      if (this.auth.currentUser?.id != this.review?.user?.id) {
        this.reviewForm.get('rating')?.disable();
        this.reviewForm.get('title')?.disable();
        this.reviewForm.get('description')?.disable();
      }
    }
  }

  translateRefresh() : void {
    const results = this.translate.instant(['global.errors']);
    this.errors_type = results['global.errors'];
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
  }

  onReviewSubmit() : void {
    if (this.reviewForm.valid) {

      const reviewData = new FormData();
      reviewData.append('review[title]', this.reviewForm.value.title);
      reviewData.append('review[rating]', this.reviewForm.value.rating ?? 0);
      reviewData.append('review[description]', this.reviewForm.value.description);
      if (!this.isEditReview) {
        reviewData.append('review[order_id]', this.order_id?.toString() || '');
      }
      if (this.reviewImageUrls.length > 0) {
        this.reviewImageUrls.forEach((image : any) => {
          reviewData.append('review[images][]', image.signedId ?? image.file);
        });
      }
      if (this.isEditReview) {
        this.reviewService.updateReview(this.review?.id || -1, reviewData).subscribe((response : ApiResponseModel | ReviewModel) => {
          if (response instanceof ReviewModel) {
            this.refreshReview(response);
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
        this.reviewService.createReview(reviewData).subscribe((response : ApiResponseModel | ReviewModel) => {
          if (response instanceof ReviewModel) {
            this.refreshReview(response);
            this.deleteReviewDialogVisible = false;
            this.isEditReview = true;
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

  clearReviewForm() : void {
    this.reviewForm.reset();
    this.reviewImageUrls = [];
  }

  DeleteReview() : void {
    this.reviewService.deleteReview(this.review?.id || -1).subscribe((response : ApiResponseModel | ReviewModel) => {
      
      if (response instanceof ReviewModel) {
        this.deleteReviewDialogVisible = false;
        this.isEditReview = false;
        this.clearReviewForm();
        this.messageService.add({
          severity: 'success',
          summary: this.errors_type["summary_success"],
          detail: this.errors_type["deleted_success"]
        });
      }else{
        this.messageService.add({
          severity: 'error',
          summary: this.errors_type["summary_error"],
          detail: this.errors_type["deleted_error"]
        });
      }
    });
  }

  deleteImage(url: string) : void {
    this.reviewImageUrls = this.reviewImageUrls.filter((image : ImageAttachmentModel) => image.url != url);
  }

  refreshReview(review: ReviewModel) : void {
    this.reviewForm.patchValue({
      title: review.title,
      rating: review.rating,
      description: review.description
    });
    this.reviewImageUrls = review.imageUrls;
  }
}
