import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormControl, Validators, AbstractControl } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { ImportsModule } from '../../../imports';
import { DropdownModule } from 'primeng/dropdown';
import { RequestService } from '../../services/request.service';
import { ColorModel } from '../../models/color.model';
import { PrinterModel } from '../../models/printer.model';
import { PresetModel } from '../../models/preset.model';
import { PresetService } from '../../services/preset.service';
import { StlModelViewerModule } from 'angular-stl-model-viewer';
import { FilamentModel } from '../../models/filament.model';
import { FormGroup } from '@angular/forms';
import { FileSelectEvent, FileUploadEvent } from 'primeng/fileupload';
import { RequestModel } from '../../models/request.model';
import { MessageService } from 'primeng/api';

@Component({
  selector: 'app-request-form',
  imports: [ImportsModule, DropdownModule, StlModelViewerModule],
  templateUrl: './request-form.component.html',
  styleUrl: './request-form.component.css'
})
export class RequestFormComponent implements OnInit {
  isEditMode = false;
  isNewMode = false;
  isViewMode = false;
  id: number | null = null;
  uploadedFile: any = null;
  uploadedFileBlob: any = null;
  deleteDialogVisible: boolean = false;
  requestToDelete: RequestModel | null = null;

  request: any = {
    name: '',
    budget: '',
    targetDate: '',
    comment: '',
    presets: []
  }
  printers: { label: string, value: string, id: number }[] = [];
  filamentTypes: { label: string, value: string, id: number }[] = [];
  colors: { label: string, value: string, id: number }[] = [];

  form!: FormGroup;

  constructor(private router: Router, private route: ActivatedRoute,
    private requestService: RequestService, private presetService: PresetService, private fb: FormBuilder, private messageService: MessageService) {
    //init form empty
    this.form = this.fb.group({
      name: new FormControl('', [Validators.required, Validators.minLength(3)]),
      budget: new FormControl('', [Validators.required, Validators.min(0), Validators.max(10000)]),
      targetDate: new FormControl('', [Validators.required, this.dateValidator]),
      comment: new FormControl('')
    });
  }

  dateValidator(control: AbstractControl) {
    const date = new Date(control.value);
    if (date < new Date()) {
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

    this.presetService.getAllPrinters().subscribe((printers) => {
      this.printers = printers.map((printer: PrinterModel) => ({ label: printer.model, value: printer.model, id: printer.id }));
    });

    this.presetService.getAllFilaments().subscribe((filamentTypes) => {
      this.filamentTypes = filamentTypes.map((filament: FilamentModel) => ({ label: filament.name, value: filament.name, id: filament.id }));
    });

    this.presetService.getAllColors().subscribe((colors) => {
      this.colors = colors.map((color: ColorModel) => ({ label: color.name, value: color.name, id: color.id }));
    });



    if (this.isEditMode || this.isViewMode) {
      if (this.id !== null) {
        this.requestService.getRequestById(this.id).subscribe((request) => {
          this.request = request;

          if (this.request === null) {
            this.router.navigate(['/requests']);
          }

          this.form = this.fb.group({
            name: [{ value: this.request.name, disabled: this.isViewMode }, Validators.required],
            budget: [{ value: this.request.budget, disabled: this.isViewMode }, Validators.required],
            targetDate: [{ value: this.request.targetDate, disabled: this.isViewMode }, Validators.required],
            comment: [{ value: this.request.comment, disabled: this.isViewMode }]
          });

        });
      }
    }

    if (this.isNewMode) {
      this.request = {
        name: '',
        budget: '',
        targetDate: '',
        comment: '',
        presets: []
      };
    }
  }

  removePreset(index: number): void {
    this.request.presets.splice(index, 1);
  }

  onFileUpload(event: FileSelectEvent): void {
    console.log('File uploaded:', event);
    const file = event.files[0];
    this.uploadedFile = file;

    const reader = new FileReader();
    reader.onloadend = () => {
      this.uploadedFileBlob = reader.result;
      console.log('File:', this.uploadedFileBlob);
    };
    reader.readAsArrayBuffer(file);
  }

  saveChanges(): void {
    console.log('Request saved:', this.request);
    this.router.navigate(['/requests']);
  }

  deleteRequest(): void {
    console.log('Request deleted:', this.request);
    this.requestService.deleteRequest(this.request.id).subscribe((response) => {
      if (response.status === 200) {
        this.router.navigate(['/requests']);
      }
    });
  }

  cancelEdit(): void {
    this.router.navigate(['/requests/view', this.id]);
  }

  cancelNew(): void {
    this.router.navigate(['/requests']);
  }

  makeAnOffer(): void {
    console.log('Offer made:', this.request);
  }

  addPreset(): void {
    this.request.presets.push({ printer: '', filamentType: '', color: '', printQuality: '0.12' });
  }

  createRequest() {
    if (this.form.valid) {
      console.log('Request form:', this.form.value);

      const contestFormData = new FormData();

      contestFormData.append('request[name]', this.form.value.name);
      contestFormData.append('request[budget]', this.form.value.budget);
      contestFormData.append('request[target_date]', this.form.value.targetDate);
      contestFormData.append('request[comment]', this.form.value.comment);

      if (this.uploadedFile) {
        contestFormData.append('request[stl_file]', this.uploadedFile);
      }

      if (this.request.presets.length > 0) {
        this.request.presets.forEach((preset: any, index: number) => {
          // Find the corresponding objects in your dropdown arrays
          const printer = this.printers.find((p: any) => p.label === preset.printer);
          const filament = this.filamentTypes.find((f: any) => f.label === preset.filamentType);
          const color = this.colors.find((c: any) => c.label === preset.color);
          console.log('Printer:', printer, 'Filament:', filament, 'Color:', color);

          // Ensure that each selection is found before appending
          if (this.request.presets.length > 0) {
            this.request.presets.forEach((preset: any, index: number) => {
              // Assuming preset.printer, preset.filamentType, and preset.color now contain the id values,
              // we find the full object from our dropdown arrays by comparing the id (value).
              const printer = this.printers.find((p: any) => p.value == preset.printerModel);
              const filament = this.filamentTypes.find((f: any) => f.value == preset.filamentType);
              const color = this.colors.find((c: any) => c.value == preset.color);
              console.debug('Printer:', printer, 'Filament:', filament, 'Color:', color);

              // Ensure that each selection is found before appending
              if (printer && filament && color && preset.printQuality) {
                contestFormData.append(
                  `request[preset_requests_attributes][${index}][printer_id]`,
                  printer.id.toString()
                );
                contestFormData.append(
                  `request[preset_requests_attributes][${index}][filament_id]`,
                  filament.id.toString()
                );
                contestFormData.append(
                  `request[preset_requests_attributes][${index}][color_id]`,
                  color.id.toString()
                );
                contestFormData.append(
                  `request[preset_requests_attributes][${index}][print_quality]`,
                  preset.printQuality
                );
              } else {
                console.error('Missing matching printer, filament, or color for preset:', preset);
              }
            });
          }

          // Log the form data entries to verify contents (browsers may not show FormData when logged directly)
          for (const [key, value] of contestFormData.entries()) {
            console.log(`${key}: ${value}`);
          }

          const obs = this.requestService.createRequest(contestFormData);

          obs.subscribe(response => {
            if ((this.isEditMode && response.status === 200)) {
              this.messageService.add({ severity: 'success', summary: 'Success', detail: 'Request updated successfully' });
              this.router.navigate(['/requests/view', this.id]);
            } else if (response.status === 201) {
              this.messageService.add({ severity: 'success', summary: 'Success', detail: 'Request created successfully' });
              this.router.navigate(['/requests']);
            } else {
              this.messageService.add({ severity: 'error', summary: 'Error', detail: 'Request creation failed' });
            }
          });
        }
        );
      }
    }
  }

  downloadFile(downloadUrl: string): void {
    console.log('Download file:', downloadUrl);
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
}

