import { Component, OnInit, OnChanges, SimpleChanges } from '@angular/core';
import { FormBuilder, FormControl, Validators, AbstractControl } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { ImportsModule } from '../../../imports';
import { DropdownModule } from 'primeng/dropdown';
import { RequestService } from '../../services/request.service';
import { ColorModel } from '../../models/color.model';
import { PrinterModel } from '../../models/printer.model';
import { PresetService } from '../../services/preset.service';
import { StlModelViewerModule } from 'angular-stl-model-viewer';
import { FilamentModel } from '../../models/filament.model';
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

@Component({
  selector: 'app-request-form',
  imports: [ImportsModule, DropdownModule, StlModelViewerModule, OfferModalComponent, TranslatePipe],
  templateUrl: './request-form.component.html',
  styleUrl: './request-form.component.css'
})
export class RequestFormComponent implements OnInit, OnChanges {
  isEditMode = false;
  isNewMode = false;
  isViewMode = false;
  id: number | null = null;
  isMine: boolean = false;
  uploadedFile: any = null;
  uploadedFileBlob: any = null;
  deleteDialogVisible: boolean = false;
  offerModalVisible: boolean = false;
  presetModalToEdit: any = null;
  requestToDelete: RequestModel | null = null;
  presetToDelete: any[] = [];
  todayDate = new Date().toISOString().substring(0, 10);

  isDragOver: boolean = false;

  request: any = {
    name: '',
    budget: '',
    targetDate: '',
    comment: '',
    presets: []
  };

  printers: { label: string, value: string, id: number }[] = [];
  filamentTypes: { label: string, value: string, id: number }[] = [];
  colors: { label: string, value: string, id: number }[] = [];

  form: FormGroup = new FormGroup({
    name: new FormControl('', [Validators.required, Validators.minLength(3)]),
    budget: new FormControl('', [Validators.required, Validators.min(0), Validators.max(10000)]),
    targetDate: new FormControl('', [Validators.required]),
    comment: new FormControl('', Validators.maxLength(200))
  });

  constructor(
    private router: Router,
    private route: ActivatedRoute,
    private requestService: RequestService,
    private presetService: PresetService,
    private fb: FormBuilder,
    private messageService: MessageService,
    private authService: AuthService,
    private translate: TranslateService
  ) {
    this.dateValidator = this.dateValidator.bind(this);
  }

  dateValidator(control: AbstractControl) {
    const selectedDate = new Date(control.value);
    if (isNaN(selectedDate.getTime())) {
      return { dateError: true };
    }

    if (this.request && selectedDate.toISOString().substring(0, 10) === this.request.targetDate) {
      return null;
    }

    const today = new Date();

    if (selectedDate < today) {
      return { dateError: true };
    }
    return null;
  }

  ngOnInit(): void {
    const action = this.route.snapshot.url[0]?.path;
    this.id = this.route.snapshot.params['id'];
    this.isEditMode = action === 'edit';
    this.isNewMode = action === 'new';
    this.isViewMode = action === 'view';

    if (this.isEditMode && !this.id) {
      this.router.navigate(['/requests']);
    }

    if (this.isEditMode || this.isNewMode) {
      console.log('Loading all presets for edit...');
      this.presetService.getAllPrinters().subscribe((printers) => {
        this.printers = printers.map((printer: PrinterModel) => ({
          label: printer.model,
          value: printer.model,
          id: printer.id
        }));
      });

      this.presetService.getAllFilaments().subscribe((filamentTypes) => {
        this.filamentTypes = filamentTypes.map((filament: FilamentModel) => ({
          label: filament.name,
          value: filament.name,
          id: filament.id
        }));
      });

      this.presetService.getAllColors().subscribe((colors) => {
        this.colors = colors.map((color: ColorModel) => ({
          label: color.name,
          value: color.name,
          id: color.id
        }));
      });
    }

    if ((this.isEditMode || this.isViewMode) && this.id !== null) {
      this.requestService.getRequestById(this.id).subscribe((response) => {
        if (response instanceof ApiResponseModel) {
          console.error('An error occured while fetching data:', response);
          this.router.navigate(['/requests']);
          return;
        }

        if (response instanceof RequestModel) {
          this.request = response;
          console.log('Request loaded:', this.request);
          this.isMine = response.user?.id === this.authService.currentUser?.id;

          if (this.isViewMode) {
            console.log('Loading only preset info...');
            this.colors = this.request.presets.map((preset: RequestPresetModel) => ({
              label: preset.color.name,
              value: preset.color.name,
              id: preset.color.id
            }));
            console.log('Colors detected:', this.colors);
            this.filamentTypes = this.request.presets.map((preset: RequestPresetModel) => ({
              label: preset.filamentType.name,
              value: preset.filamentType.name,
              id: preset.filamentType.id
            }));
            console.log('Filament types detected:', this.filamentTypes);
            this.printers = this.request.presets.map((preset: RequestPresetModel) => ({
              label: preset.printerModel.model,
              value: preset.printerModel.model,
              id: preset.printerModel.id
            }));
            console.log('Printers detected:', this.printers);
          }

          if (this.isMine && this.isViewMode) {
            this.router.navigate(['/requests/edit', this.id]);
          }
          if (!this.isMine && this.isEditMode) {
            this.router.navigate(['/requests/view', this.id]);
          }

          this.form = this.fb.group({
            name: [{ value: this.request.name, disabled: this.isViewMode || this.request.hasOfferAccepted }, [Validators.required, Validators.minLength(3)]],
            budget: [{ value: this.request.budget, disabled: this.isViewMode || this.request.hasOfferAccepted }, [Validators.required, Validators.min(0), Validators.max(10000)]],
            targetDate: [{ value: new Date(this.request.targetDate).toISOString().substring(0, 10), disabled: this.isViewMode || this.request.hasOfferAccepted }, [Validators.required, this.dateValidator]],
            comment: [{ value: this.request.comment, disabled: this.isViewMode || this.request.hasOfferAccepted }, Validators.maxLength(200)]
          });
        } else { //Not instance of RequestModel
          console.error('Invalid request data received:', response);
          this.router.navigate(['/requests']);
        }
      });
    }

    if (this.isNewMode) {
      this.request = {
        name: '',
        budget: '',
        targetDate: '',
        comment: '',
        presets: []
      };

      this.form = this.fb.group({
        name: ['', [Validators.required, Validators.minLength(3)]],
        budget: ['', [Validators.required, Validators.min(0), Validators.max(10000)]],
        targetDate: ['', [Validators.required, this.dateValidator]],
        comment: ['', Validators.maxLength(200)]
      });
    }
  }

  removePreset(index: number): void {
    const preset = this.request.presets[index];
    if (!preset.id) {
      this.request.presets.splice(index, 1);
      return;
    }
    preset._destroy = true;
    this.request.presets.splice(index, 1);
    this.presetToDelete.push(preset);
  }

  onFileUpload(event: FileSelectEvent): void {
    console.log('File uploaded:', event);
    const file = event.files[0];
    this.uploadedFile = file;
    const reader = new FileReader();
    reader.onloadend = () => {
      this.uploadedFileBlob = reader.result;
      console.log('File loaded:', this.uploadedFileBlob);
    };
    reader.readAsArrayBuffer(file);
  }


  submitRequest(): void {
    if (this.form.invalid) {
      console.log('Invalid form:', this.form);
      this.messageService.add({
        severity: 'error',
        summary: 'Error',
        detail: 'Please fix the errors in the form before submitting.'
      });
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

    if (!this.appendPresets(formData)) {
      this.messageService.add({
        severity: 'error',
        summary: this.translate.instant('requestForm.invalid_preset'),
        detail: this.translate.instant('requestForm.invalid_preset_message')
      });
      return;
    }

    // for (const [key, value] of formData.entries()) {
    //   console.log(`${key}: ${value}`);
    // }

    if (this.isEditMode) {
      this.requestService.updateRequest(this.request.id, formData).subscribe(response => {
        // if (response.status === 200) {
        //   this.router.navigate(['/requests/view', this.request.id]);
        // }
      });
    } else if (this.isNewMode) {
      this.requestService.createRequest(formData).subscribe(response => {
        if (response.status === 201) {
          this.router.navigate(['/requests/edit', response.data.request.id]);
        }
      });
    }
  }

  private appendPresets(formData: FormData): boolean {
    let presetIndex = 0;
    let hasError = false;

    if (this.request.presets && this.request.presets.length > 0) {
      for (const preset of this.request.presets) {
        const printer = this.printers.find((p: any) => p.label === preset.printerModel.model);
        const filament = this.filamentTypes.find((f: any) => f.label === preset.filamentType.name);
        const color = this.colors.find((c: any) => c.label === preset.color.name);
        console.log('Preset:', preset);
        if (printer && filament && color && preset.printQuality && this.isPresetValid(preset)) {
          if (preset.id) {
            formData.append(`request[preset_requests_attributes][${presetIndex}][id]`, preset.id.toString());
          }
          formData.append(`request[preset_requests_attributes][${presetIndex}][printer_id]`, printer.id.toString());
          formData.append(`request[preset_requests_attributes][${presetIndex}][filament_id]`, filament.id.toString());
          formData.append(`request[preset_requests_attributes][${presetIndex}][color_id]`, color.id.toString());
          formData.append(`request[preset_requests_attributes][${presetIndex}][print_quality]`, preset.printQuality);
          presetIndex++;
        } else {
          hasError = true;
          console.error('Invalid preset:', preset);
        }
      }
    }

    if (this.presetToDelete && this.presetToDelete.length > 0) {
      for (const preset of this.presetToDelete) {
        if (preset.id) {
          formData.append(`request[preset_requests_attributes][${presetIndex}][id]`, preset.id.toString());
          formData.append(`request[preset_requests_attributes][${presetIndex}][_destroy]`, '1');
          presetIndex++;
        }
      }
    }

    return !hasError;
  }

  deleteRequest(): void {
    this.requestService.deleteRequest(this.request.id).subscribe((response) => {
      if (response.status === 200) {
        this.router.navigate(['/requests']);
      }
    });
  }

  cancelEdit(): void {
    this.router.navigate(['/requests'], { queryParams: { tab: 'mine' } });
  }

  cancelNew(): void {
    this.router.navigate(['/requests']);
  }

  addPreset(): void {
    this.request.presets.push({
      printerModel: { model: '' },
      filamentType: { name: '' },
      color: { name: '' },
      printQuality: 0.16
    });
  }

  downloadFile(downloadUrl: string): void {
    window.open(downloadUrl, '_blank');
  }

  showDeleteDialog(request: RequestModel): void {
    this.requestToDelete = request;
    this.deleteDialogVisible = true;
  }

  confirmDelete(): void {
    if (this.requestToDelete !== null) {
      this.requestService.deleteRequest(this.requestToDelete.id).subscribe(() => {
        this.router.navigate(['/requests']);
      });
    }
    this.deleteDialogVisible = false;
  }

  makeAnOffer(): void {
    this.offerModalVisible = true;
  }

  isPresetValid(preset: any): boolean {
    const printerValid = !!this.printers.find((p: any) => p.label === preset.printerModel.model);
    const filamentValid = !!this.filamentTypes.find((f: any) => f.label === preset.filamentType.name);
    const colorValid = !!this.colors.find((c: any) => c.label === preset.color.name);

    const isDuplicate = this.request.presets.filter((p: any) =>
      p.printerModel.model === preset.printerModel.model &&
      p.filamentType.name === preset.filamentType.name &&
      p.color.name === preset.color.name &&
      p.printQuality === preset.printQuality
    ).length > 1;

    return printerValid && filamentValid && colorValid && preset.printQuality && !isDuplicate;
  }

  showOfferModal(preset?: any): void {
    this.offerModalVisible = true;

    console.log('Editing preset from form:', preset);
    this.presetModalToEdit = preset;

  }

  hideOfferModal(): void {
    this.offerModalVisible = false;
  }

  ngOnChanges(changes: SimpleChanges): void {
    console.log('Changes in request form:', changes);
  }


  // Drag and drop
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
          console.log('File loaded:', this.uploadedFileBlob);
        };
        reader.readAsArrayBuffer(file);
      }
    }
  }
}