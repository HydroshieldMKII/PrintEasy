import { Component, EventEmitter, Input, OnInit, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ImportsModule } from '../../../imports';
import { FormsModule } from '@angular/forms';
import { StlModelViewerModule } from 'angular-stl-model-viewer';
import { TranslatePipe } from '@ngx-translate/core';
import { RequestPresetModel } from '../../models/request-preset.model';
import { PresetModel } from '../../models/preset.model';

@Component({
  selector: 'app-request-presets',
  standalone: true,
  imports: [ImportsModule, FormsModule, StlModelViewerModule, TranslatePipe, CommonModule],
  templateUrl: './request-preset.component.html',
  styleUrl: './request-preset.component.css'
})

export class RequestPresetComponent implements OnInit {
  @Input() presets: RequestPresetModel[] = [];
  @Input() printers: { label: string, value: string, id: number }[] = [];
  @Input() filamentTypes: { label: string, value: string, id: number }[] = [];
  @Input() colors: { label: string, value: string, id: number }[] = [];
  @Input() isViewMode: boolean = false;
  @Input() isEditMode: boolean = false;
  @Input() isNewMode: boolean = false;
  @Input() hasOffers: boolean = false;
  @Input() hasOfferAccepted: boolean = false;
  @Input() presetToDelete: any[] = [];

  @Output() removePresetEvent = new EventEmitter<number>();
  @Output() undoDeletePresetEvent = new EventEmitter<PresetModel>();
  @Output() showOfferModalEvent = new EventEmitter<any>();
  @Output() addPresetEvent = new EventEmitter<void>();

  constructor() { }

  ngOnInit(): void {
  }

  removePreset(index: number): void {
    this.removePresetEvent.emit(index);
  }

  undoDeletePreset(preset: PresetModel): void {
    this.undoDeletePresetEvent.emit(preset);
  }

  showOfferModal(preset?: any): void {
    this.showOfferModalEvent.emit(preset);
  }

  addPreset(): void {
    this.addPresetEvent.emit();
  }

  isPresetValid(preset: any): boolean {
    const printerValid = preset.printerModel && preset.printerModel.id !== null;
    const filamentValid = preset.filamentType && preset.filamentType.id !== null;
    const colorValid = preset.color && preset.color.id !== null;

    preset.printQuality = parseFloat(preset.printQuality);

    const isMarkedForDeletion = this.presetToDelete.some((p: any) =>
      preset.id && p.id === preset.id
    );

    if (isMarkedForDeletion) {
      return true;
    }

    const duplicateCount = this.presets.filter((p: any) => {
      const pQuality = parseFloat(p.printQuality);
      const currentQuality = preset.printQuality;

      return p.printerModel.id === preset.printerModel.id &&
        p.filamentType.id === preset.filamentType.id &&
        p.color.id === preset.color.id &&
        pQuality === currentQuality;
    }).length;

    return printerValid && filamentValid && colorValid && !isNaN(preset.printQuality) && duplicateCount <= 1;
  }

  isAboutToBeDeleted(preset: PresetModel): boolean {
    return this.presetToDelete.some((p: PresetModel) => p.id === preset.id);
  }
}