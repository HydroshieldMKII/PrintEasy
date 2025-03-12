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
import { LikeModel } from '../../models/like.model';
import { UserContestSubmissionsModel } from '../../models/user-contest-submissions.model';
import { ApiResponseModel } from '../../models/api-response.model';
import { UserProfileService } from '../../services/user-profile.service';
import { UserModel } from '../../models/user.model';
import { Renderer2 } from '@angular/core';
import { TranslatePipe } from '@ngx-translate/core';
import { Router, ActivatedRoute } from '@angular/router';
import { UserProfileModel } from '../../models/user-profile.model';
import { TranslateService } from '@ngx-translate/core';

@Component({
  selector: 'app-user-profile',
  imports: [ImportsModule, TranslatePipe],
  templateUrl: './user-profile.component.html',
  styleUrl: './user-profile.component.css',
})
export class UserProfileComponent implements OnInit {
  readonly authService = inject(AuthService);
  readonly submissionService = inject(SubmissionService);
  readonly reviewService = inject(ReviewService);
  readonly likeService = inject(LikeService);
  readonly presetService = inject(PresetService);
  readonly messageService = inject(MessageService);
  readonly printerUserService = inject(PrinterUserService);
  readonly userProfileService = inject(UserProfileService);
  readonly translate = inject(TranslateService);
  readonly fb = inject(FormBuilder);
  readonly router = inject(ActivatedRoute);
  readonly route = inject(Router);

  userContestSubmissions: UserContestSubmissionsModel[] = [];
  responsiveOptions: any[] | undefined;
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
  userProfile: UserProfileModel | null | undefined = undefined;

  constructor(private renderer: Renderer2) {
    this.printerForm = this.fb.group({
      printer: [null, Validators.required],
      aquiredDate: [null, Validators.required],
    });

    this.router.params.subscribe((params) => {
      if (params['id']) {
        this.userProfileService
          .getUserProfile(params['id'])
          .subscribe((response: UserProfileModel | ApiResponseModel) => {
            if (response instanceof UserProfileModel) {
              this.userProfile = response;
            } else {
              if (response.status === 404) {
                this.route.navigate(['/']);
              }
            }
          });
      }
    });

    this.likeService.getLikes().subscribe((response) => {
      this.userLikes = response;
    });

    this.responsiveOptions = [
      {
        breakpoint: '1400px',
        numVisible: 2,
        numScroll: 1,
      },
      {
        breakpoint: '1199px',
        numVisible: 3,
        numScroll: 1,
      },
      {
        breakpoint: '767px',
        numVisible: 2,
        numScroll: 1,
      },
      {
        breakpoint: '575px',
        numVisible: 1,
        numScroll: 1,
      },
    ];
  }

  ngOnInit() {
    this.loadPrinterList();
  }

  loadContestSubmissions() {
    this.submissionService
      .getUserContestSubmissions(this.router.snapshot.params['id'])
      .subscribe((submissions) => {
        this.userContestSubmissions = submissions;
      });
  }

  loadPrinterUsers() {
    this.printerUserService.getPrinterUsers().subscribe((printerUsers) => {
      this.printerUsers = printerUsers;
    });
  }

  loadPrinterList() {
    this.presetService.getAllPrinters().subscribe((printers) => {
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
    this.printerUserEdit = printerUser;

    this.printerForm.patchValue({
      printer: printerUser.printer,
      aquiredDate: new Date(printerUser.aquiredDate),
    });
    this.printerDialogVisible = true;
  }

  showDeleteDialog(printerUser: PrinterUserModel) {
    this.printerToDelete = printerUser;
    this.deleteDialogVisible = true;
  }

  confirmDelete() {
    if (this.printerToDelete) {
      this.printerUserService
        .deletePrinterUser(this.printerToDelete.id)
        .subscribe((response) => {
          if (response.status === 200) {
            this.userProfile!.printerUsers =
              this.userProfile!.printerUsers.filter(
                (pu) => pu.id !== this.printerToDelete?.id
              );
            this.messageService.add({
              severity: 'success',
              summary: this.translate.instant('global.success'),
              detail: this.translate.instant('profile.printer_deleted'),
            });
            this.deleteDialogVisible = false;
            this.printerToDelete = null;
          } else if (
            response.errors?.['base'] ==
            'Cannot delete printer user with orders'
          ) {
            this.messageService.add({
              severity: 'error',
              summary: 'Error',
              detail: 'Cannot delete printer user with orders',
            });
            this.deleteDialogVisible = false;
            this.printerToDelete = null;
          }
        });
    }
  }

  onPrinterSubmit() {
    if (!this.printerForm.valid) return;

    const submitAction$ =
      this.isEditMode && this.printerUserEdit
        ? this.printerUserService.updatePrinterUser(
            this.printerForm,
            this.printerUserEdit.id
          )
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
            detail: `Printer ${
              this.isEditMode ? 'updated' : 'added'
            } successfully`,
          });
          if (this.isEditMode && this.printerUserEdit) {
            const index = this.userProfile?.printerUsers.findIndex(
              (pu) => pu.id === this.printerUserEdit?.id
            );
            if (index !== undefined && index !== -1) {
              this.userProfile!.printerUsers[index] = PrinterUserModel.fromAPI(
                response.data.printer_user
              );
            }
          } else {
            this.userProfile?.printerUsers.push(
              PrinterUserModel.fromAPI(response.data.printer_user)
            );
          }
        } else {
          this.messageService.add({
            severity: 'error',
            summary: 'Error',
            detail: `Printer not ${this.isEditMode ? 'updated' : 'added'}`,
          });
        }
      },
      error: () => {
        this.messageService.add({
          severity: 'error',
          summary: this.translate.instant('global.error'),
          detail: this.isEditMode
            ? this.translate.instant('user_profile.printer.printer_not_updated')
            : this.translate.instant('user_profile.printer.printer_not_added'),
        });
      },
      complete: () => {
        this.printerDialogVisible = false;
        this.printerForm.reset();
      },
    });
  }

  onLike(submission: SubmissionModel) {
    if (submission.liked) {
      const like = submission.likes.find(
        (like) => like.userId === this.authService.currentUser?.id
      );
      this.likeService.deleteLike(like?.id).subscribe((response) => {
        const deletedLike = LikeModel.fromApi(response.data.like);
        submission.likes = submission.likes.filter(
          (l) => l.id !== deletedLike.id
        );
        submission.liked = false;
      });
    } else {
      this.likeService.createLike(submission.id).subscribe((response) => {
        const newLike = LikeModel.fromApi(response.data.like);
        submission.likes.push(newLike);
        submission.liked = true;
      });
    }
  }
}
