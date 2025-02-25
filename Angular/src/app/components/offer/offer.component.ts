import { Component } from '@angular/core';
import { SelectItem } from 'primeng/api';
import { Router, RouterLink } from '@angular/router';
import { OfferModel } from '../../models/offer.model';
import { OfferService } from '../../services/offer.service';
import { ImportsModule } from '../../../imports';
import { MessageService } from 'primeng/api';
import { Clipboard } from '@angular/cdk/clipboard';
import { OfferModalComponent } from '../offer-modal/offer-modal.component';

@Component({
  selector: 'app-offer',
  imports: [ImportsModule, RouterLink, OfferModalComponent],
  templateUrl: './offer.component.html',
  styleUrls: ['./offer.component.css']
})
export class OffersComponent {
  activeTab: string = 'mine';
  offers: OfferModel[] | null = null;
  myOffers: OfferModel[] | null = null;

  deleteDialogVisible: boolean = false;
  offerToDelete: OfferModel | null = null;

  isOwningPrinter: boolean | null = null;
  expandedRowKeys: { [key: number]: boolean } = {};

  onTabChange(tab: string): void {
    console.log('Tab changed:', tab);
    this.activeTab = tab;
    this.router.navigate([], { queryParams: { tab: this.activeTab }, queryParamsHandling: 'merge' });

    if (this.activeTab === 'all' && !this.offers) {
      this.offerService.getOffers().subscribe((offers: OfferModel[]) => {
        this.offers = offers;
      });
    }
    if (this.activeTab === 'mine' && !this.myOffers) {
      this.offerService.getMyOffers().subscribe((offers: OfferModel[]) => {
        this.myOffers = offers
      });
    }
  }

  get currentOffers(): OfferModel[] {
    return this.activeTab === 'mine' ? this.myOffers || [] : this.offers || [];
  }

  constructor(private offerService: OfferService, private router: Router, private messageService: MessageService, private clipboard: Clipboard) {
    const queryParams = this.router.parseUrl(this.router.url).queryParams;

    // set tab
    this.activeTab = queryParams['tab'] || 'mine';
    this.router.navigate([], { queryParams: { tab: this.activeTab }, queryParamsHandling: 'merge' });

    if (this.activeTab === 'all') {
      this.offerService.getOffers().subscribe((offers: OfferModel[]) => {
        this.offers = offers;
      });
    } else if (this.activeTab === 'mine') {
      console.log('Getting my offers');
      this.offerService.getMyOffers().subscribe((offers: OfferModel[]) => {
        console.log('Got my offers:', offers);
        this.myOffers = offers;
      });
    }
  }


  onRowExpand(event: any): void {
    console.log("Expanding row:", event.data.id);
    this.expandedRowKeys = {};  // Reset previous expanded rows
    this.expandedRowKeys[event.data.id] = true;  // Expand only the clicked row
  }

  onRowCollapse(event: any): void {
    console.log("Collapsing row:", event.data.id);
    delete this.expandedRowKeys[event.data.id];  // Remove the collapsed row
  }

  isRowExpanded(rowId: number): boolean {
    return !!this.expandedRowKeys[rowId];  // Check if this row is expanded
  }

  downloadRequest(downloadUrl: string): void {
    console.log('Download request:', downloadUrl);
    window.open(downloadUrl, '_blank');
  }

  showDeleteDialog(request: OfferModel): void {
    this.offerToDelete = request;
    this.deleteDialogVisible = true;
  }

  confirmDelete(): void {
    if (this.offerToDelete !== null) {
      // this.offerService.deleteOffer(this.offerToDelete.id).subscribe(() => {
      //   this.offers = (this.offers || []).filter(r => r.id !== this.offerToDelete?.id);
      //   this.myOffers = (this.myOffers || []).filter(r => r.id !== this.offerToDelete?.id);
      // });
    }
    this.deleteDialogVisible = false;
  }

  copyToClipboard(text: string): void {
    const fullUrl = new URL(text, window.location.origin).href;
    console.log('Copied to clipboard:', fullUrl);
    this.clipboard.copy(fullUrl);
    this.messageService.add({ severity: 'success', summary: 'Copied request to clipboard' });
  }

  editOffer(offer: OfferModel): void {
    console.log("editing id: ", offer.id)
  }

  cancelOffer(offer: OfferModel) {
    console.log("Canceling id: ", offer.id)
  }

  acceptOffer(offer: OfferModel) {
    console.log("Accepting id: ", offer.id)
  }

  refuseOffer(offer: OfferModel) {
    console.log("Rejecting id: ", offer.id)
  }
}

