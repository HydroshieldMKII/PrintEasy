import { Component, inject, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MessageService } from 'primeng/api';
import { ImportsModule } from '../../../imports';
import { AuthService } from '../../services/authentication.service';
import { PresetService } from '../../services/preset.service';
import { PrinterUserModel } from '../../models/printer-user.model';
import { PrinterModel } from '../../models/printer.model';
import { SubmissionService } from '../../services/submission.service';
import { ReviewService } from '../../services/review.service';
import { LikeService } from '../../services/like.service';
import { ReviewModel } from '../../models/review.model';
import { SubmissionModel } from '../../models/submission.model';
import { UserContestSubmissionsModel } from '../../models/user-contest-submissions.model';
import { Renderer2 } from '@angular/core';


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
  readonly fb = inject(FormBuilder);

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

    // this.reviewService.getUserReviews().subscribe(response => {
    //   if (response.data && response.data.reviews) {
    //     this.userReviews = response.data.reviews;
    //     this.averageRating = this.userReviews.length > 0
    //       ? this.userReviews.reduce((acc, review) => acc + review.rating, 0) / this.userReviews.length
    //       : 0;
    //   }
    // });
  }

  ngOnInit() {
    this.loadPrinterUsers();
    this.loadPrinterList();
  }

  loadPrinterUsers() {
    this.presetService.getPrinterUsers().subscribe(printerUsers => {
      console.log("Printer user loaded", printerUsers);
      this.printerUsers = printerUsers;
    });
  }

  loadPrinterList() {
    this.presetService.getAllPrinters().subscribe(printers => {
      console.log("Printers loaded", printers);
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
    if (this.printerForm.valid) {
      const formValues = this.printerForm.value;

      if (this.isEditMode) {
        this.messageService.add({
          severity: 'success',
          summary: 'Success',
          detail: 'Printer updated successfully'
        });
      } else {

        // const newPrinterUser: PrinterUserModel = {
        //   user: this.authService.currentUser!,
        //   printer: formValues.printer,
        //   aquiredDate: formValues.aquiredDate
        // };

        // this.printerUsers.push(newPrinterUser);
        this.messageService.add({
          severity: 'success',
          summary: 'Success',
          detail: 'Printer added successfully'
        });
      }

      this.printerDialogVisible = false;
      this.printerForm.reset();
    }
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