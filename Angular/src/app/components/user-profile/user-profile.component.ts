import { Component, inject, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MessageService } from 'primeng/api';
import { ImportsModule } from '../../../imports';
import { AuthService } from '../../services/authentication.service';
import { PresetService } from '../../services/preset.service';
import { PrinterUserModel } from '../../models/printer-user.model';
import { PrinterModel } from '../../models/printer.model';
import { PrinterUserService } from '../../services/printer-user.service';
import { SubmissionService } from '../../services/submission.service';
import { ReviewService } from '../../services/review.service';
import { LikeService } from '../../services/like.service';
import { ReviewModel } from '../../models/review.model';
import { SubmissionModel } from '../../models/submission.model';
import { UserContestSubmissionsModel } from '../../models/user-contest-submissions.model';
import { ApiResponseModel } from '../../models/api-response.model';
import { Renderer2 } from '@angular/core';
import { ActivatedRoute } from '@angular/router';



@Component({
  selector: 'app-user-profile',
  imports: [ImportsModule],
  templateUrl: './user-profile.component.html',
  styleUrl: './user-profile.component.css'
})
export class UserProfileComponent implements OnInit {
  readonly authService = inject(AuthService);
  readonly submissionService = inject(SubmissionService);
  readonly reviewService = inject(ReviewService);
  readonly likeService = inject(LikeService);
  readonly presetService = inject(PresetService);
  readonly messageService = inject(MessageService);
  readonly printerUserService = inject(PrinterUserService);
  readonly fb = inject(FormBuilder);
  route: ActivatedRoute = inject(ActivatedRoute);

  userContestSubmissions: UserContestSubmissionsModel[] = [];
  responsiveOptions: any[] | undefined;
  userReviews: ReviewModel[] = [];
  userLikes: SubmissionModel[] = [];
  averageRating: number = 0;
  tab: string = 'contest-submissions';
  prints = 3;

  printerUsers: PrinterUserModel[] = [];
  availablePrinters: PrinterModel[] = [];
  printerDialogVisible: boolean = false;
  deleteDialogVisible: boolean = false;
  printerToDelete: PrinterUserModel | null = null;
  isEditMode: boolean = false;
  printerUserEdit: PrinterUserModel | null = null;
  printerForm: FormGroup;
  today = new Date();

  constructor(private renderer: Renderer2) {
    this.printerForm = this.fb.group({
      printer: [null, Validators.required],
      aquiredDate: [null, Validators.required]
    });

    this.submissionService.getUserContestSubmissions().subscribe(submissions => {
      this.userContestSubmissions = submissions;
    });

    this.likeService.getLikes().subscribe(response => {
      this.userLikes = response;
    });

    this.responsiveOptions = [
      {
        breakpoint: '575px',
        numVisible: 1,
        numScroll: 1
      }
    ];

    this.reviewService.getUserReviews(this.route.snapshot.params['id']).subscribe((response: ApiResponseModel | ReviewModel[]) => {
      if (response instanceof ApiResponseModel) {
        return;
      }
      this.userReviews = response;
      console.log("reviews", this.userReviews)
      this.averageRating = this.userReviews.reduce((acc, review) => acc + review.rating, 0) / this.userReviews.length;
    });
  }

  ngOnInit() {
    this.loadPrinterUsers();
    this.loadPrinterList();
  }

  loadPrinterUsers() {
    this.printerUserService.getPrinterUsers().subscribe(printerUsers => {
      this.printerUsers = printerUsers;
    });
  }

  loadPrinterList() {
    this.presetService.getAllPrinters().subscribe(printers => {
      this.availablePrinters = printers;
    });
  }

  showAddPrinterDialog() {
    this.isEditMode = false;
    this.printerForm.reset();
    this.printerDialogVisible = true;
  }

  editPrinter(printerUser: PrinterUserModel) {
    this.isEditMode = true;
    this.printerUserEdit = printerUser

    this.printerForm.patchValue({
      printer: printerUser.printer,
      aquiredDate: new Date(printerUser.aquiredDate)
    });
    this.printerDialogVisible = true;
  }

  showDeleteDialog(printerUser: PrinterUserModel) {
    this.printerToDelete = printerUser;
    this.deleteDialogVisible = true;
  }

  confirmDelete() {
    if (this.printerToDelete) {
      this.printerUsers = this.printerUsers.filter(p => p.id !== this.printerToDelete?.id);
      this.messageService.add({
        severity: 'success',
        summary: 'Success',
        detail: 'Printer deleted successfully'
      });
      this.deleteDialogVisible = false;
      this.printerToDelete = null;
    }
  }

  onPrinterSubmit() {
    if (!this.printerForm.valid) return;
  
    const submitAction$ = this.isEditMode && this.printerUserEdit 
      ? this.printerUserService.updatePrinterUser(this.printerForm, this.printerUserEdit.id)
      : this.printerUserService.createPrinterUser(this.printerForm);
  
    submitAction$.subscribe({
      next: (response) => {
        const isSuccessful = this.isEditMode 
          ? response.status === 200 
          : response.status === 201;
  
        if (isSuccessful) {
          this.messageService.add({
            severity: 'success',
            summary: 'Success',
            detail: `Printer ${this.isEditMode ? 'updated' : 'added'} successfully`
          });
          this.loadPrinterUsers();
        } else {
          console.error('Error:', response.errors);
          this.messageService.add({
            severity: 'error',
            summary: 'Error',
            detail: `Printer not ${this.isEditMode ? 'updated' : 'added'}`
          });
        }
      },
      error: (error) => {
        console.error('Submission error:', error);
        this.messageService.add({
          severity: 'error',
          summary: 'Error',
          detail: `An error occurred while ${this.isEditMode ? 'updating' : 'adding'} the printer`
        });
      },
      complete: () => {
        this.printerDialogVisible = false;
        this.printerForm.reset();
      }
    });
  }

  onLike(submission: SubmissionModel) {
    if (submission.liked) {
      const like = submission.likes.find(like => like.userId === this.authService.currentUser?.id);
      this.likeService.deleteLike(like?.id).subscribe(() => {
        this.userLikes = this.userLikes.filter(like => like.id !== submission.id);
      });
    }
  }
}