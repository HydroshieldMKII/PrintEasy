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

  request: any = {
    name: '',
    budget: '',
    targetDate: '',
    comment: '',
    presets: []
  }
  printers: { label: string, value: string }[] = [];
  filamentTypes: { label: string, value: string }[] = [];
  colors: { label: string, value: string }[] = [];

  form!: FormGroup;

  constructor(private router: Router, private route: ActivatedRoute,
    private requestService: RequestService, private presetService: PresetService, private fb: FormBuilder) {
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
      this.printers = printers.map((printer: PrinterModel) => ({ label: printer.model, value: printer.model })); // Ensure value is a string
    });

    this.presetService.getAllFilaments().subscribe((filamentTypes) => {
      this.filamentTypes = filamentTypes.map((filament: FilamentModel) => ({ label: filament.name, value: filament.name })); // Convert to string
    });

    this.presetService.getAllColors().subscribe((colors) => {
      this.colors = colors.map((color: ColorModel) => ({ label: color.name, value: color.name })); // Convert to string
    });


    if (this.isEditMode || this.isViewMode) {
      if (this.id !== null) {
        this.requestService.getRequestById(this.id).subscribe((request) => {
          this.request = request;

          this.form = this.fb.group({
            name: [{ value: this.request.name, disabled: this.isViewMode }, Validators.required],
            budget: [{ value: this.request.budget, disabled: this.isViewMode }, Validators.required],
            targetDate: [{ value: this.request.targetDate, disabled: this.isViewMode }, Validators.required],
            comment: [{ value: this.request.comment, disabled: this.isViewMode }]
          });

          if (this.request === null) {
            this.router.navigate(['/requests']);
          }
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
    this.router.navigate(['/requests']);
  }

  cancelEdit(): void {
    this.router.navigate(['/requests/view', this.id]);
  }

  cancelNew(): void {
    this.router.navigate(['/requests']);
  }

  // Row edit functions
  onRowEditInit(preset: any) {
    console.log('Edit Init:', preset);
  }

  onRowEditSave(preset: any) {
    console.log('Edit Save:', preset);
  }

  onRowEditCancel(preset: any, index: number) {
    console.log('Edit Canceled:', preset);
  }

  makeAnOffer(): void {
    console.log('Offer made:', this.request);
  }

  addPreset(): void {
    this.request.presets.push({ printer: '', filamentType: '', color: '', printQuality: '0.12' });
  }

  createRequest() {
    if (this.form.valid) {
      console.log('Données du concours:', this.form.value);

      const contestFormData = new FormData();

      contestFormData.append('request[name]', this.form.value.name);
      contestFormData.append('request[budget]', this.form.value.budget);
      contestFormData.append('request[target_date]', this.form.value.targetDate);
      contestFormData.append('request[comment]', this.form.value.comment);


      if (this.uploadedFile) {
        contestFormData.append('request[stl_file]', this.uploadedFile);
      }

      // const obs = this.isEditMode
      //   ? this.requestService.updateRequest(this.id, contestFormData)
      //   : this.requestService.createRequest(contestFormData);

      const obs = this.requestService.createRequest(contestFormData);

      obs.subscribe(response => {
        if ((this.isEditMode && response.status === 200) || (!this.isNewMode && response.status === 201)) {
          this.router.navigate(['/requests']);
        }
      });
    }
  }

  downloadFile(downloadUrl: string): void {
    console.log('Download file:', downloadUrl);
    window.open(downloadUrl, '_blank');
  }
}

