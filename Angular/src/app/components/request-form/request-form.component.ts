import { Component, OnInit } from '@angular/core';
import {
  FormBuilder,
  FormControl,
  Validators,
  AbstractControl,
} from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { ImportsModule } from '../../../imports';
import { DropdownModule } from 'primeng/dropdown';
import { RequestService } from '../../services/request.service';
import { PresetService } from '../../services/preset.service';
import { StlModelViewerModule } from 'angular-stl-model-viewer';
import { FormGroup } from '@angular/forms';
import { FileSelectEvent } from 'primeng/fileupload';
import { RequestModel } from '../../models/request.model';
import { MessageService } from 'primeng/api';
import { AuthService } from '../../services/authentication.service';
import { RequestPresetModel } from '../../models/request-preset.model';
import { OfferModalComponent } from '../offer-modal/offer-modal.component';
import { TranslatePipe } from '@ngx-translate/core';
import { TranslateService } from '@ngx-translate/core';
import { ApiResponseModel } from '../../models/api-response.model';
import { PresetModel } from '../../models/preset.model';
import { RequestPresetComponent } from '../request-preset/request-preset.component';
import { TranslationService } from '../../services/translation.service';

@Component({
  selector: 'app-request-form',
  imports: [
    ImportsModule,
    DropdownModule,
    StlModelViewerModule,
    OfferModalComponent,
    TranslatePipe,
    RequestPresetComponent,
  ],
  templateUrl: './request-form.component.html',
  styleUrl: './request-form.component.css',
})
export class RequestFormComponent implements OnInit {
  isEditMode = false;
  isNewMode = false;
  isViewMode = false;
  id: number | null = null;
  isMine: boolean = false;
  uploadedFile: Blob | null = null;
  uploadedFileBlob: any = null;
  deleteDialogVisible: boolean = false;
  offerModalVisible: boolean = false;
  presetModalToEdit: PresetModel | null = null;
  requestToDelete: RequestModel | null = null;
  presetToDelete: any[] = [];

  isDragOver: boolean = false;

  request: any = {
    name: '',
    budget: '',
    targetDate: '',
    comment: '',
    presets: [],
  };

  printers: { label: string; value: string; id: number }[] = [];
  filamentTypes: { label: string; value: string; id: number }[] = [];
  colors: { label: string; value: string; id: number }[] = [];

  form: FormGroup = new FormGroup({
    name: new FormControl('', [Validators.required, Validators.minLength(3)]),
    budget: new FormControl('', [
      Validators.required,
      Validators.min(0),
      Validators.max(10000),
    ]),
    targetDate: new FormControl('', [Validators.required]),
    comment: new FormControl('', Validators.maxLength(200)),
  });

  constructor(
    private router: Router,
    private route: ActivatedRoute,
    private requestService: RequestService,
    private presetService: PresetService,
    private fb: FormBuilder,
    private messageService: MessageService,
    private authService: AuthService,
    private translate: TranslateService,
    private translationService: TranslationService
  ) {
    this.dateValidator = this.dateValidator.bind(this);

    this.translate.onLangChange.subscribe(() => {
      this.translateRefresh();
    });
    this.translateRefresh();
  }

  get hasOfferAccepted(): boolean {
    return this.request && this.request.acceptedAt;
  }

  translateRefresh(): void {
    this.colors = this.colors.map((color: any) => {
      color.label = this.translationService.translateColor(color.id);
      color.value = color.label;
      return color;
    });

    this.filamentTypes = this.filamentTypes.map((filament: any) => {
      filament.label = this.translationService.translateFilament(filament.id);
      filament.value = filament.label;
      return filament;
    });

    this.request.presets = this.request.presets.map((preset: any) => {
      const matchingColor = this.colors.find(
        (c: any) => c.id === preset.color.id
      );
      const matchingFilament = this.filamentTypes.find(
        (f: any) => f.id === preset.filamentType.id
      );
      const matchingPrinter = this.printers.find(
        (p: any) => p.id === preset.printerModel.id
      );

      if (matchingColor) {
        preset.color = { ...matchingColor };
      }

      if (matchingFilament) {
        preset.filamentType = { ...matchingFilament };
      }

      if (matchingPrinter) {
        preset.printerModel = { ...matchingPrinter };
      }

      return preset;
    });
  }

  dateValidator(control: AbstractControl) {
    const selectedDate = new Date(control.value);
    if (isNaN(selectedDate.getTime())) {
      return { dateError: true };
    }

    if (
      this.request?.targetDate &&
      selectedDate.toISOString().substring(0, 10) ===
        this.request.targetDate.toISOString().substring(0, 10)
    ) {
      return null;
    }

    const today = new Date();

    if (selectedDate < today) {
      return { dateError: true };
    }
    return null;
  }

  ngOnInit(): void {
    this.presetToDelete = [];
    const action = this.route.snapshot.url[0]?.path;
    this.id = this.route.snapshot.params['id'];
    this.isEditMode = action === 'edit';
    this.isNewMode = action === 'new';
    this.isViewMode = action === 'view';

    if (this.isEditMode && !this.id) {
      this.router.navigate(['/requests']);
      return;
    }

    if (this.isEditMode || this.isNewMode) {
      this.loadReferenceData();
    }

    if ((this.isEditMode || this.isViewMode) && this.id !== null) {
      this.loadRequestData();
    }

    if (this.isNewMode) {
      this.initializeNewRequest();
    }
  }

  private loadReferenceData(): void {
    this.presetService.getAllPrinters().subscribe((printers) => {
      this.printers = this.mapEntityToDropdownOptions(printers, 'model');
    });

    this.presetService.getAllFilaments().subscribe((filamentTypes) => {
      this.filamentTypes = this.mapEntityToDropdownOptions(
        filamentTypes,
        'name'
      );
    });

    this.presetService.getAllColors().subscribe((colors) => {
      this.colors = this.mapEntityToDropdownOptions(colors, 'name');
    });
  }

  private mapEntityToDropdownOptions(
    entities: any[],
    labelProperty: string
  ): any[] {
    return entities.map((entity) => ({
      label: entity[labelProperty],
      value: entity[labelProperty],
      id: entity.id,
    }));
  }

  private loadRequestData(): void {
    this.requestService.getRequestById(this.id!).subscribe((response) => {
      if (response instanceof ApiResponseModel) {
        this.router.navigate(['/requests']);
        return;
      }

      if (response instanceof RequestModel) {
        this.request = response;
        this.isMine = response.user?.id === this.authService.currentUser?.id;

        if (this.isViewMode) {
          this.mapPresetsToDropdownOptions();
        }

        this.handleRequestOwnership();
        this.initializeEditForm();
      } else {
        this.router.navigate(['/requests']);
      }
    });
  }

  private mapPresetsToDropdownOptions(): void {
    this.colors = this.request.presets.map((preset: RequestPresetModel) => ({
      label: preset.color.name,
      value: preset.color.name,
      id: preset.color.id,
    }));

    this.filamentTypes = this.request.presets.map(
      (preset: RequestPresetModel) => ({
        label: preset.filamentType.name,
        value: preset.filamentType.name,
        id: preset.filamentType.id,
      })
    );

    this.printers = this.request.presets.map((preset: RequestPresetModel) => ({
      label: preset.printerModel.model,
      value: preset.printerModel.model,
      id: preset.printerModel.id,
    }));
  }

  private handleRequestOwnership(): void {
    if (this.isMine && this.isViewMode) {
      this.router.navigate(['/requests/edit', this.id]);
    }

    if (!this.isMine && this.isEditMode) {
      this.router.navigate(['/requests/view', this.id]);
    }
  }

  private initializeEditForm(): void {
    this.form = this.fb.group({
      name: [
        {
          value: this.request.name,
          disabled: this.isViewMode,
        },
        [Validators.required, Validators.minLength(3)],
      ],
      budget: [
        {
          value: this.request.budget,
          disabled: this.isViewMode,
        },
        [Validators.required, Validators.min(0), Validators.max(10000)],
      ],
      targetDate: [
        {
          value: new Date(this.request.targetDate)
            .toISOString()
            .substring(0, 10),
          disabled: this.isViewMode,
        },
        [Validators.required, this.dateValidator],
      ],
      comment: [
        {
          value: this.request.comment,
          disabled: this.isViewMode,
        },
        Validators.maxLength(200),
      ],
    });
  }

  private initializeNewRequest(): void {
    this.request = {
      name: '',
      budget: '',
      targetDate: '',
      comment: '',
      presets: [],
    };

    this.form = this.fb.group({
      name: [
        '',
        [
          Validators.required,
          Validators.minLength(3),
          Validators.maxLength(30),
        ],
      ],
      budget: [
        0.0,
        [Validators.required, Validators.min(0), Validators.max(10000)],
      ],
      targetDate: ['', [Validators.required, this.dateValidator]],
      comment: ['', Validators.maxLength(200)],
    });
  }

  removePreset(index: number): void {
    const preset = this.request.presets[index];

    //new preset not saved
    if (!preset.id) {
      this.request.presets.splice(index, 1);
      return;
    }

    this.presetToDelete.push({ ...preset });
  }

  isAboutToBeDeleted(preset: PresetModel): boolean {
    return this.presetToDelete.some((p: PresetModel) => p.id === preset.id);
  }

  undoDeletePreset(preset: PresetModel): void {
    this.presetToDelete = this.presetToDelete.filter(
      (p: PresetModel) => p.id !== preset.id
    );
  }

  submitRequest(): void {
    if (this.form.invalid) {
      return;
    }

    this.request.name = this.form.value.name;
    this.request.budget = this.form.value.budget;
    this.request.targetDate = this.form.value.targetDate;
    this.request.comment = this.form.value.comment;

    const formData = new FormData();
    formData.append('request[name]', this.request.name);
    formData.append('request[budget]', this.request.budget);
    formData.append('request[target_date]', this.request.targetDate);
    formData.append('request[comment]', this.request.comment);
    if (this.uploadedFile) {
      formData.append('request[stl_file]', this.uploadedFile);
    }

    // Append presets to form + validations
    if (!this.appendPresets(formData)) {
      this.messageService.add({
        severity: 'error',
        summary: this.translate.instant('requestForm.invalid_preset'),
        detail: this.translate.instant('requestForm.invalid_preset_message'),
      });
      return;
    }

    const operation = this.isEditMode
      ? this.requestService.updateRequest(this.request.id, formData)
      : this.requestService.createRequest(formData);

    operation.subscribe((response) => {
      if (
        (this.isEditMode && response.status === 200) ||
        (this.isNewMode && response.status === 201)
      ) {
        this.request.presets = this.request.presets.filter(
          (preset: any) =>
            !this.presetToDelete.some((p: any) => p.id === preset.id)
        );
        this.presetToDelete = [];

        if (this.isEditMode) {
          this.refreshRequestDetails();
        } else {
          this.router.navigate(['/requests/edit', response.data.request.id]);
        }
      }
    });
  }

  private appendPresets(formData: FormData): boolean {
    let presetIndex = 0;
    let hasError = false;

    if (this.request.presets && this.request.presets.length > 0) {
      for (const preset of this.request.presets) {
        if (
          preset.printerModel.id &&
          preset.filamentType.id &&
          preset.color.id &&
          preset.printQuality &&
          this.isPresetValid(preset)
        ) {
          if (preset.id) {
            formData.append(
              `request[preset_requests_attributes][${presetIndex}][id]`,
              preset.id.toString()
            );
          }

          formData.append(
            `request[preset_requests_attributes][${presetIndex}][printer_id]`,
            preset.printerModel.id.toString()
          );
          formData.append(
            `request[preset_requests_attributes][${presetIndex}][filament_id]`,
            preset.filamentType.id.toString()
          );
          formData.append(
            `request[preset_requests_attributes][${presetIndex}][color_id]`,
            preset.color.id.toString()
          );
          formData.append(
            `request[preset_requests_attributes][${presetIndex}][print_quality]`,
            preset.printQuality.toString()
          );
          presetIndex++;
        } else {
          hasError = true;
        }
      }
    }

    if (this.presetToDelete && this.presetToDelete.length > 0) {
      const processedIds = new Set();

      for (const preset of this.presetToDelete) {
        if (preset.id && !processedIds.has(preset.id)) {
          formData.append(
            `request[preset_requests_attributes][${presetIndex}][id]`,
            preset.id.toString()
          );
          formData.append(
            `request[preset_requests_attributes][${presetIndex}][_destroy]`,
            '1'
          );
          presetIndex++;

          processedIds.add(preset.id);
        }
      }
    }

    return !hasError;
  }

  cancelEdit(): void {
    this.router.navigate(['/requests'], { queryParams: { tab: 'mine' } });
  }

  cancelNew(): void {
    this.router.navigate(['/requests']);
  }

  addPreset(): void {
    this.request.presets.push({
      printerModel: { id: null, model: '', label: '', value: '' },
      filamentType: { id: null, name: '', label: '', value: '' },
      color: { id: null, name: '', label: '', value: '' },
      printQuality: 0.16,
    });
  }

  showDeleteDialog(request: RequestModel): void {
    this.requestToDelete = request;
    this.deleteDialogVisible = true;
  }

  confirmDelete(): void {
    if (this.requestToDelete !== null) {
      this.requestService
        .deleteRequest(this.requestToDelete.id)
        .subscribe(() => {
          this.router.navigate(['/requests']);
        });
    }
    this.deleteDialogVisible = false;
  }

  isPresetValid(preset: any): boolean {
    const printerValid = preset.printerModel && preset.printerModel.id !== null;
    const filamentValid =
      preset.filamentType && preset.filamentType.id !== null;
    const colorValid = preset.color && preset.color.id !== null;

    preset.printQuality = parseFloat(preset.printQuality);

    const isMarkedForDeletion = this.presetToDelete.some(
      (p: any) => preset.id && p.id === preset.id
    );

    if (isMarkedForDeletion) {
      const duplicateDeleteCount = this.presetToDelete.filter((p: any) => {
        return (
          p.printerModel.id === preset.printerModel.id &&
          p.filamentType.id === preset.filamentType.id &&
          p.color.id === preset.color.id &&
          parseFloat(p.printQuality) === preset.printQuality
        );
      }).length;

      return duplicateDeleteCount <= 1;
    }

    const activePresets = this.request.presets.filter((p: any) => {
      return !this.presetToDelete.some((dp: any) => dp.id && dp.id === p.id);
    });

    const duplicateCount = activePresets.filter((p: any) => {
      const pQuality = parseFloat(p.printQuality);
      const currentQuality = preset.printQuality;

      return (
        p.printerModel.id === preset.printerModel.id &&
        p.filamentType.id === preset.filamentType.id &&
        p.color.id === preset.color.id &&
        pQuality === currentQuality
      );
    }).length;

    return (
      printerValid &&
      filamentValid &&
      colorValid &&
      !isNaN(preset.printQuality) &&
      duplicateCount <= 1
    );
  }

  showOfferModal(preset?: any): void {
    this.offerModalVisible = true;
    this.presetModalToEdit = preset;
  }

  hideOfferModal(): void {
    this.offerModalVisible = false;
  }

  // upload file button
  onFileUpload(event: FileSelectEvent): void {
    const file = event.files[0];
    this.uploadedFile = file;
    const reader = new FileReader();
    reader.onloadend = () => {
      this.uploadedFileBlob = reader.result;
    };
    reader.readAsArrayBuffer(file);
  }

  downloadFile(downloadUrl: string): void {
    window.open(downloadUrl, '_blank');
  }

  // Drag and drop events
  onDragOver(event: DragEvent): void {
    event.preventDefault();
    event.stopPropagation();
    this.isDragOver = true;
  }

  onDragLeave(event: DragEvent): void {
    event.preventDefault();
    event.stopPropagation();
    this.isDragOver = false;
  }

  onDrop(event: DragEvent): void {
    event.preventDefault();
    event.stopPropagation();
    this.isDragOver = false;

    if (event.dataTransfer && event.dataTransfer.files) {
      const files = event.dataTransfer.files;
      if (files.length > 0) {
        const file = files[0];

        this.uploadedFile = file;
        const reader = new FileReader();
        reader.onloadend = () => {
          this.uploadedFileBlob = reader.result;
        };
        reader.readAsArrayBuffer(file);
      }
    }
  }

  refreshRequestDetails(): void {
    if (!this.id) {
      return;
    }
    this.requestService.getRequestById(this.id).subscribe((response) => {
      if (response instanceof RequestModel) {
        this.request = response;
      }
    });
  }
}
