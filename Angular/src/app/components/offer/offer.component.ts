import { Component } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { OfferService } from '../../services/offer.service';
import { MessageService } from 'primeng/api';
import { Clipboard } from '@angular/cdk/clipboard';
import { OfferModalComponent } from '../offer-modal/offer-modal.component';
import { ImportsModule } from '../../../imports';

@Component({
  selector: 'app-offer',
  imports: [ImportsModule, OfferModalComponent, RouterLink],
  templateUrl: './offer.component.html',
  styleUrls: ['./offer.component.css']
})
export class OffersComponent {
  activeTab: string = 'mine';
  // The API now returns a list of Request objects with nested offers
  offers: any[] | null = null;  // For "all" offers (received)
  myOffers: any[] | null = null; // For "my" pending offers

  deleteDialogVisible: boolean = false;
  offerToDelete: any | null = null;
  requestToDelete: any | null = null;
  isOwningPrinter: boolean | null = null;

  // Use the native API structure directly
  get currentRequests(): any[] {
    return this.activeTab === 'mine' ? this.myOffers || [] : this.offers || [];
  }

  constructor(
    private offerService: OfferService,
    private router: Router,
    private messageService: MessageService,
    private clipboard: Clipboard
  ) {
    const queryParams = this.router.parseUrl(this.router.url).queryParams;
    this.activeTab = queryParams['tab'] || 'mine';
    this.router.navigate([], { queryParams: { tab: this.activeTab }, queryParamsHandling: 'merge' });

    if (this.activeTab === 'all') {
      this.offerService.getOffers().subscribe((requests: any[]) => {
        this.offers = requests;
      });
    } else if (this.activeTab === 'mine') {
      this.offerService.getMyOffers().subscribe((requests: any[]) => {
        console.log("requests:", requests);
        this.myOffers = requests;
      });
    }
  }

  onTabChange(tab: string): void {
    this.activeTab = tab;
    this.router.navigate([], { queryParams: { tab: this.activeTab }, queryParamsHandling: 'merge' });
    if (this.activeTab === 'all' && !this.offers) {
      this.offerService.getOffers().subscribe((requests: any[]) => {
        this.offers = requests;
      });
    }
    if (this.activeTab === 'mine' && !this.myOffers) {
      this.offerService.getMyOffers().subscribe((requests: any[]) => {
        this.myOffers = requests;
      });
    }
  }

  downloadRequest(downloadUrl: string): void {
    window.open(downloadUrl, '_blank');
  }

  showDeleteDialog(offer: any): void {
    this.offerToDelete = offer;
    this.deleteDialogVisible = true;
  }

  confirmDelete(): void {
    if (this.offerToDelete !== null && this.requestToDelete !== null) {
      this.offerService.deleteOffer(this.offerToDelete.id).subscribe((response) => {
        if (response.status === 200) {
          const index = this.requestToDelete.offers.indexOf(this.offerToDelete);
          if (index !== -1) {
            this.requestToDelete.offers.splice(index, 1);
          }
        }

        this.offerToDelete = null;
        this.requestToDelete = null;
      });
    }
    this.deleteDialogVisible = false;
  }

  copyToClipboard(text: string): void {
    const fullUrl = new URL(text, window.location.origin).href;
    this.clipboard.copy(fullUrl);
    this.messageService.add({ severity: 'success', summary: 'Copied request to clipboard' });
  }

  editOffer(offer: any): void {
    console.log("editing id:", offer.id);
  }

  cancelOffer(offer: any, request: any): void {
    console.log("Canceling:", offer);
    this.offerToDelete = offer;
    this.requestToDelete = request;
    this.deleteDialogVisible = true;
  }

  acceptOffer(offer: any): void {
    console.log("Accepting id:", offer.id);
  }

  refuseOffer(offer: any): void {
    console.log("Rejecting id:", offer.id);
  }
}
