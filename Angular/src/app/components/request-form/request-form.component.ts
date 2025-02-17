import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { ImportsModule } from '../../../imports';
import { DropdownModule } from 'primeng/dropdown';

@Component({
  selector: 'app-request-form',
  imports: [ImportsModule, DropdownModule],
  templateUrl: './request-form.component.html',
  styleUrl: './request-form.component.css'
})
export class RequestFormComponent implements OnInit {
  isEditMode = false;
  isNewMode = false;
  isViewMode = false;
  id: number | null = null;

  request: any = {
    name: '',
    budget: '',
    targetDate: '',
    comment: '',
    presets: [
      { printer: 'Bambulab P1P', filamentType: 'PLA', color: 'Red', printQuality: '0.1mm' },
      { printer: 'Bambulab P1P', filamentType: 'PLA', color: 'Blue', printQuality: '0.1mm' }
    ]
  };

  printers = ['Bambulab P1P', 'Ender 3', 'Prusa MK3S', 'Anycubic i3', 'FlashForge'];
  filamentTypes = ['PLA', 'ABS', 'PETG', 'Nylon'];
  colors = ['Red', 'Blue', 'Green', 'Black', 'White'];
  printQualities = ['0.1mm', '0.2mm', '0.3mm', '0.4mm'];

  constructor(private router: Router, private route: ActivatedRoute) { }

  ngOnInit(): void {
    const action = this.route.snapshot.url[0]?.path;

    this.id = this.route.snapshot.params['id'];
    this.isEditMode = action === 'edit';
    this.isNewMode = action === 'new';
    this.isViewMode = action === 'view';

    if (this.isEditMode && !this.id) {
      this.router.navigate(['/requests']);
    }

    if (this.isEditMode || this.isViewMode) {
      this.request = {
        name: 'Cool print idea',
        budget: '$51',
        targetDate: '2021-01-01',
        comment: 'Yessir miller',
        presets: [
          { printer: 'Bambulab P1P', filamentType: 'PLA', color: 'Red', printQuality: '0.1mm' },
          { printer: 'Bambulab P1P', filamentType: 'PLA', color: 'Blue', printQuality: '0.2mm' }
        ]

      };
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

  uploadFile(event: any): void {
    console.log('File uploaded:', event);
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
}
