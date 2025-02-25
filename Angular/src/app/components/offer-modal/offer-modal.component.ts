import { Component, Input, Output, EventEmitter } from '@angular/core';
import { ImportsModule } from '../../../imports';
import { FormGroup, FormBuilder, Validators } from '@angular/forms';
import { DropdownModule } from 'primeng/dropdown';
import { PresetService } from '../../services/preset.service';
import { OfferService } from '../../services/offer.service';
import { PresetModel } from '../../models/preset.model';
import { ColorModel } from '../../models/color.model';
import { FilamentModel } from '../../models/filament.model';
import { PrinterUserModel } from '../../models/printer-user.model';


@Component({
  selector: 'app-offer-modal',
  imports: [ImportsModule, DropdownModule],
  templateUrl: './offer-modal.component.html',
  styleUrl: './offer-modal.component.css'
})
export class OfferModalComponent {
  @Input() offerModalVisible: boolean = false;
  @Input() requestIdToEdit: number | null = null;

  @Output() offerModalVisibleChange = new EventEmitter<boolean>();

  isEditMode: boolean = false;
  printName: string = 'A cool print';
  offerForm: FormGroup;

  selectedPreset: PresetModel | null = null;
  presets: { label: string, value: string, id: number }[] = [];
  printers: { label: string, value: string, id: number }[] = [];
  filamentTypes: { label: string, value: string, id: number }[] = [];
  colors: { label: string, value: string, id: number }[] = [];
  filaments: { label: string, value: string, id: number }[] = [];

  constructor(private fb: FormBuilder, private presetService: PresetService, private offerService: OfferService) {
    this.offerForm = this.fb.group({
      preset: [this.selectedPreset],
      color: [null, Validators.required],
      filament: [null, Validators.required],
      quality: [null, [Validators.required, Validators.min(0.01), Validators.max(2)]],
      printer: [null, Validators.required],
      targetDate: [null, Validators.required],
      price: [null, [Validators.required, Validators.min(0), Validators.max(10000)]]
    });

    this.offerForm.get('preset')?.valueChanges.subscribe(selectedPreset => {
      if (selectedPreset) {
        this.onPresetSelected(selectedPreset);
      }
    });

    this.offerForm.get('color')?.valueChanges.subscribe(() => {
      this.offerForm.patchValue({ preset: null });
    });

    this.offerForm.get('filament')?.valueChanges.subscribe(() => {
      this.offerForm.patchValue({ preset: null });
    });

    this.offerForm.get('quality')?.valueChanges.subscribe(() => {
      this.offerForm.patchValue({ preset: null });
    });

    this.presetService.getAllPresets().subscribe((presets: PresetModel[]) => {
      this.presets = presets.map(preset => {
        return {
          label: `${preset.printQuality}mm - ${preset.color.name} - ${preset.filament.name}`,
          value: `${preset.printQuality}mm - ${preset.color.name} - ${preset.filament.name}`,
          id: preset.id
        };
      });
      console.log('Presets:', this.presets);
    });

    this.presetService.getPrinterUsers().subscribe((printerUsers: PrinterUserModel[]) => {
      console.log('Printer Users:', printerUsers);
      this.printers = printerUsers.map(printerUser => {
        const formattedDate = new Date(printerUser.aquired_date).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
        return { label: `${printerUser.printer.model} (${formattedDate})`, value: printerUser.printer.model, id: printerUser.id };
      });
    });

    this.presetService.getAllFilaments().subscribe((filaments: FilamentModel[]) => {
      this.filaments = filaments.map(filament => {
        return { label: filament.name, value: filament.name, id: filament.id };
      });
    });

    this.presetService.getAllColors().subscribe((colors: ColorModel[]) => {
      this.colors = colors.map(color => {
        return { label: color.name, value: color.name, id: color.id };
      });
    });
  }

  onPresetSelected(selectedPreset: any): void {
    console.log('Selected Preset:', selectedPreset);

    const preset = this.presets.find(p => p.value === selectedPreset.value);

    if (preset) {
      const [quality, color, filament] = preset.value.split(' - ');
      const matchingColor = this.colors.find(c => c.label === color);
      const matchingFilament = this.filaments.find(f => f.label === filament);

      this.offerForm.patchValue({
        quality: parseFloat(quality.replace('mm', '')),
        color: matchingColor,
        filament: matchingFilament
      });
    }
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
      const formValues = this.offerForm.value;
      const formData = new FormData();

      if (!this.requestIdToEdit) {
        console.error('Error: requestIdToEdit is not set.');
        return;
      } else {
        console.log('requestIdToEdit:', this.requestIdToEdit);
      }

      formData.append('offer[request_id]', this.requestIdToEdit.toString());
      formData.append('offer[printer_user_id]', formValues.printer.id.toString());
      formData.append('offer[color_id]', formValues.color.id.toString());
      formData.append('offer[filament_id]', formValues.filament.id.toString());
      formData.append('offer[price]', formValues.price.toString());
      formData.append('offer[print_quality]', formValues.quality.toString());
      formData.append('offer[target_date]', formValues.targetDate.toISOString());

      this.offerService.createOffer(formData).subscribe(
        response => {
          console.log('Offer created successfully:', response);
          this.closeModal();
        },
        error => {
          console.error('Error creating offer:', error);
        }
      );
    }
  }



  deleteOffer() {
    console.log('Offer Deleted');
    this.offerModalVisible = false;
  }
}
