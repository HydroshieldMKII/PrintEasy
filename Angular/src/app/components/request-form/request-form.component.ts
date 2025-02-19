import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormControl, Validators } from '@angular/forms';
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
      name: new FormControl('', Validators.required),
      budget: new FormControl('', Validators.required),
      targetDate: new FormControl('', Validators.required),
      comment: new FormControl(''),
      presets: this.fb.array([
        this.fb.group({
          printer: new FormControl('', Validators.required),
          filamentType: new FormControl('', Validators.required),
          color: new FormControl('', Validators.required),
          printQuality: new FormControl('0.12', Validators.required)
        })
      ])
    });
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
      console.log('Colors:', colors);
      this.colors = colors.map((color: ColorModel) => ({ label: color.name, value: color.name })); // Convert to string
    });


    if (this.isEditMode || this.isViewMode) {
      if (this.id !== null) {
        this.requestService.getRequestById(this.id).subscribe((request) => {
          this.request = request;
          console.log('Request viewing is now:', this.request);
          console.log('Request presets:', this.request.presets);
          console.log("Printer:", this.request.presets[0].printerModel);
          console.log("Filament:", this.request.presets[0].filamentType);
          console.log("Color:", this.request.presets[0].color);

          this.form = this.fb.group({
            name: [{ value: this.request.name, disabled: this.isViewMode }, Validators.required],
            budget: [{ value: this.request.budget, disabled: this.isViewMode }, Validators.required],
            targetDate: [{ value: this.request.targetDate, disabled: this.isViewMode }, Validators.required],
            comment: [{ value: this.request.comment, disabled: this.isViewMode }],
            presets: this.fb.array(this.request.presets.map((preset: PresetModel) => this.fb.group({
              printer: [{ value: preset.printerModel, disabled: this.isViewMode }, Validators.required],
              filamentType: [{ value: preset.filamentType, disabled: this.isViewMode }, Validators.required],
              color: [{ value: preset.color, disabled: this.isViewMode }, Validators.required],
              printQuality: [{ value: preset.printQuality, disabled: this.isViewMode }, Validators.required]
            }))
            )
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
    const reader = new FileReader();
    reader.onloadend = () => {
      this.uploadedFile = reader.result;
      console.log('File:', this.uploadedFile);
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
    if (this.isEditMode) {
      this.router.navigate(['/requests/view', this.id]);
    } else {
      this.router.navigate(['/requests']);
    }
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

  createRequest(): void {
    console.log('Request created:', this.request);

    // this.router.navigate(['/requests']);
  }

  downloadFile(downloadUrl: string): void {
    console.log('Download file:', downloadUrl);
    window.open(downloadUrl, '_blank');
  }

  onSubmit(): void {
    console.log('Form submitted:', this.form.value);
  }
}
