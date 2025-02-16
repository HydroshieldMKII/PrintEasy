import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { ImportsModule } from '../../../imports';

@Component({
  selector: 'app-request-form',
  imports: [ImportsModule],
  templateUrl: './request-form.component.html',
  styleUrl: './request-form.component.css'
})
export class RequestFormComponent implements OnInit {
  isEditMode = false;
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

  constructor(private router: Router, private route: ActivatedRoute) { }

  ngOnInit(): void {
    const action = this.route.snapshot.url[0]?.path;
    const id = this.route.snapshot.params['id'];

    this.isEditMode = action === 'edit';

    if (this.isEditMode && !id) {
      this.router.navigate(['/requests']);
    }

    this.request = {
      name: 'Cool print idea',
      budget: '$51',
      targetDate: '2021-01-01',
      comment: 'Yessir miller',
      presets: [
        { printer: 'Bambulab P1P', filamentType: 'PLA', color: 'Red', printQuality: '0.1mm' },
        { printer: 'Bambulab P1P', filamentType: 'PLA', color: 'Blue', printQuality: '0.1mm' }
      ]

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
    this.router.navigate(['/requests']);
  }
}
