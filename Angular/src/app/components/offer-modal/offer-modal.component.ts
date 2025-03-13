import {
  Component,
  Input,
  Output,
  EventEmitter,
  OnChanges,
  output,
} from '@angular/core';
import { ImportsModule } from '../../../imports';
import {
  FormGroup,
  FormBuilder,
  Validators,
  AbstractControl,
} from '@angular/forms';
import { forkJoin } from 'rxjs';
import { DropdownModule } from 'primeng/dropdown';
import { PresetService } from '../../services/preset.service';
import { PrinterUserService } from '../../services/printer-user.service';
import { OfferService } from '../../services/offer.service';
import { PresetModel } from '../../models/preset.model';
import { ColorModel } from '../../models/color.model';
import { FilamentModel } from '../../models/filament.model';
import { PrinterUserModel } from '../../models/printer-user.model';
import { MessageService } from 'primeng/api';
import { TranslatePipe } from '@ngx-translate/core';
import { TranslateService } from '@ngx-translate/core';
import { TranslationService } from '../../services/translation.service';

@Component({
  selector: 'app-offer-modal',
  imports: [ImportsModule, DropdownModule, TranslatePipe],
  templateUrl: './offer-modal.component.html',
  styleUrl: './offer-modal.component.css',
})
export class OfferModalComponent implements OnChanges {
  @Input() offerModalVisible: boolean = false;
  @Input() requestIdToEdit: number | null = null;
  @Input() offerIdToEdit: number | null = null;
  @Input() presetToEdit: any | null = null;

  @Output() offerModalVisibleChange = new EventEmitter<boolean>();
  @Output() offerUpdated = new EventEmitter<boolean>();

  originalDate: Date | null = null;
  isEditMode: boolean = false;
  printName: string = 'A cool print';
  offerForm: FormGroup;

  selectedPreset: PresetModel | null = null;
  presets: { label: string; value: string; id: number }[] = [];
  printers: {
    label: string | undefined;
    value: string | undefined;
    id: number | undefined;
    idPrinterUser: number | undefined;
  }[] = [];
  filamentTypes: { label: string; value: string; id: number }[] = [];
  colors: { label: string; value: string; id: number }[] = [];
  filaments: { label: string; value: string; id: number }[] = [];

  constructor(
    private fb: FormBuilder,
    private presetService: PresetService,
    private offerService: OfferService,
    private printerUserService: PrinterUserService,
    private translate: TranslateService,
    private translationService: TranslationService
  ) {
    this.dateValidator = this.dateValidator.bind(this);

    this.offerForm = this.fb.group({
      preset: [this.selectedPreset],
      color: [null, Validators.required],
      filament: [null, Validators.required],
      quality: [
        null,
        [Validators.required, Validators.min(0.01), Validators.max(2)],
      ],
      printer: [null, Validators.required],
      targetDate: [null, [Validators.required, this.dateValidator]],
      price: [
        null,
        [Validators.required, Validators.min(0), Validators.max(10000)],
      ],
    });

    this.offerForm.get('preset')?.valueChanges.subscribe((selectedPreset) => {
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
      this.presets = presets.map((preset) => {
        return {
          label: `${preset.printQuality}mm - ${preset.color.name} - ${preset.filament.name}`,
          value: `${preset.printQuality}mm - ${preset.color.name} - ${preset.filament.name}`,
          id: preset.id,
        };
      });
    });

    this.printerUserService
      .getPrinterUsers()
      .subscribe((printerUsers: PrinterUserModel[]) => {
        this.printers = printerUsers.map((printerUser) => {
          return {
            label: `${printerUser?.printer?.model}`,
            value: printerUser?.printer?.model,
            id: printerUser?.printer?.id,
            idPrinterUser: printerUser.id,
          };
        });
      });

    this.presetService
      .getAllFilaments()
      .subscribe((filaments: FilamentModel[]) => {
        this.filaments = filaments.map((filament) => {
          return {
            label: filament.name,
            value: filament.name,
            id: filament.id,
          };
        });
      });

    this.presetService.getAllColors().subscribe((colors: ColorModel[]) => {
      this.colors = colors.map((color) => {
        return { label: color.name, value: color.name, id: color.id };
      });
    });

    this.translate.onLangChange.subscribe(() => {
      this.translateRefresh();
    });
    this.translateRefresh();
  }

  translateRefresh() {
    this.colors = this.colors.map((color) => {
      return {
        label: this.translationService.translateColor(color.id),
        value: color.value,
        id: color.id,
      };
    });

    this.filaments = this.filaments.map((filament) => {
      return {
        label: this.translationService.translateFilament(filament.id),
        value: filament.value,
        id: filament.id,
      };
    });
  }

  dateValidator(control: AbstractControl) {
    const selectedDate = new Date(control.value);
    if (isNaN(selectedDate.getTime())) {
      return { dateError: true };
    }

    if (this.offerForm && this.originalDate) {
      const targetDateValue = this.offerForm.get('targetDate')?.value;
      if (
        targetDateValue &&
        this.originalDate &&
        this.originalDate.toISOString().substring(0, 10) ===
          new Date(targetDateValue).toISOString().substring(0, 10)
      ) {
        return null;
      }
    }

    const today = new Date();

    if (selectedDate < today) {
      return { dateError: true };
    }
    return null;
  }

  onPresetSelected(selectedPreset: any): void {
    const preset = this.presets.find((p) => p.value === selectedPreset.value);

    if (preset) {
      const [quality, color, filament] = preset.value.split(' - ');
      const matchingColor = this.colors.find((c) => c.label === color);
      const matchingFilament = this.filaments.find((f) => f.label === filament);

      this.offerForm.patchValue({
        quality: parseFloat(quality.replace('mm', '')),
        color: matchingColor,
        filament: matchingFilament,
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
    this.offerIdToEdit = null;
    this.requestIdToEdit = null;
    this.presetToEdit = null;

    this.offerForm.reset();
    this.offerModalVisibleChange.emit(false);
  }

  submitOffer() {
    if (this.offerForm.valid) {
      const formValues = this.offerForm.value;
      const formData = new FormData();

      if (!this.requestIdToEdit && !this.offerIdToEdit) {
        return;
      }

      if (this.requestIdToEdit) {
        formData.append('offer[request_id]', this.requestIdToEdit.toString());
      }
      formData.append(
        'offer[printer_user_id]',
        formValues.printer.idPrinterUser.toString()
      );
      formData.append('offer[color_id]', formValues.color.id.toString());
      formData.append('offer[filament_id]', formValues.filament.id.toString());
      formData.append('offer[price]', formValues.price.toString());
      formData.append('offer[print_quality]', formValues.quality.toString());
      formData.append('offer[target_date]', formValues.targetDate);

      let submitObs;
      if (this.offerIdToEdit) {
        formData.append('offer[id]', this.offerIdToEdit.toString());
        submitObs = this.offerService.updateOffer(this.offerIdToEdit, formData);
      } else {
        submitObs = this.offerService.createOffer(formData);
      }

      submitObs.subscribe((response) => {
        if (response.status === 200 || response.status === 201) {
          this.offerUpdated.emit(true);

          this.offerModalVisible = false;
          this.offerModalVisibleChange.emit(false);
        }
      });
    }
  }

  deleteOffer() {
    this.offerModalVisible = false;
  }

  ngOnChanges() {
    forkJoin({
      colors: this.presetService.getAllColors(),
      printers: this.printerUserService.getPrinterUsers(),
      filaments: this.presetService.getAllFilaments(),
    }).subscribe(({ colors, printers, filaments }) => {
      this.colors = colors.map((color) => ({
        label: this.translationService.translateColor(color.id),
        value: color.name,
        id: color.id,
      }));
      this.printers = printers.map((printerUser) => {
        return {
          label: `${printerUser.printer.model}`,
          value: printerUser.printer.model,
          id: printerUser.printer.id,
          idPrinterUser: printerUser.id,
        };
      });
      this.filaments = filaments.map((filament) => ({
        label: this.translationService.translateFilament(filament.id),
        value: filament.name,
        id: filament.id,
      }));

      if (this.offerIdToEdit) {
        this.offerService
          .getOfferById(this.offerIdToEdit)
          .subscribe((offer: any) => {
            let matchingPrinter = this.printers.find(
              (p) => p.idPrinterUser === offer.printerUser.id
            );
            const matchingColor = this.colors.find(
              (c) => c.id === offer.color.id
            );
            const matchingFilament = this.filaments.find(
              (f) => f.id === offer.filament.id
            );

            //timezone adjustment
            const dateFromBackend = new Date(offer.targetDate);
            dateFromBackend.setMinutes(
              dateFromBackend.getMinutes() + dateFromBackend.getTimezoneOffset()
            );

            this.offerForm.patchValue({
              printer: matchingPrinter,
              color: matchingColor,
              filament: matchingFilament,
              price: offer.price,
              quality: offer.printQuality,
              targetDate: dateFromBackend,
            });

            this.originalDate = dateFromBackend;
            this.offerForm.get('targetDate')?.updateValueAndValidity();
          });
      }

      if (this.presetToEdit) {
        this.originalDate = null;

        const matchingColor = this.colors.find(
          (c) => c.id === this.presetToEdit?.color.id
        );
        const matchingFilament = this.filaments.find(
          (f) => f.id === this.presetToEdit?.filamentType.id
        );
        const matchingPrinter = this.printers.find(
          (p) => p.id === this.presetToEdit?.printerModel.id
        );

        this.offerForm.patchValue({
          color: matchingColor,
          filament: matchingFilament,
          quality: this.presetToEdit.printQuality,
          printer: matchingPrinter,
        });
      }
    });

    if (!this.presetToEdit) {
      this.offerForm.reset();
    }
  }
}
