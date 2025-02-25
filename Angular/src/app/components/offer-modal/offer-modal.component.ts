import { Component, Input, Output, EventEmitter } from '@angular/core';
import { ImportsModule } from '../../../imports';
import { FormGroup, FormBuilder, Validators } from '@angular/forms';
import { DropdownModule } from 'primeng/dropdown';

@Component({
  selector: 'app-offer-modal',
  imports: [ImportsModule, DropdownModule],
  templateUrl: './offer-modal.component.html',
  styleUrl: './offer-modal.component.css'
})
export class OfferModalComponent {
  @Input() offerModalVisible: boolean = false;
  @Output() offerModalVisibleChange = new EventEmitter<boolean>();

  isEditMode: boolean = false;
  printName: string = 'A cool print';
  offerForm: FormGroup;

  constructor(private fb: FormBuilder,) {
    this.offerForm = this.fb.group({
      preset: [null],
      type: [null, Validators.required],
      color: [null, Validators.required],
      filament: [null, Validators.required],
      printer: [null, Validators.required],
      targetDate: [null, Validators.required],
      price: [null, [Validators.required, Validators.min(0)]]
    });
  }

  openOfferModal(editMode = false, offerData: any = null) {
    this.isEditMode = editMode;
    this.offerModalVisible = true;

    if (editMode && offerData) {
      this.offerForm.patchValue(offerData);
    } else {
      this.offerForm.reset();
    }
  }

  closeModal(): void {
    this.offerModalVisible = false;
    this.offerModalVisibleChange.emit(false);
  }

  submitOffer() {
    if (this.offerForm.valid) {
      console.log('Offer Submitted:', this.offerForm.value);
      this.offerModalVisible = false;
    }
  }

  deleteOffer() {
    console.log('Offer Deleted');
    this.offerModalVisible = false;
  }
}
