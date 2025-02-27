import { Component } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { OfferService } from '../../services/offer.service';
import { OrderService } from '../../services/order.service';
import { MessageService } from 'primeng/api';
import { Clipboard } from '@angular/cdk/clipboard';
import { OfferModalComponent } from '../offer-modal/offer-modal.component';
import { ImportsModule } from '../../../imports';
import { TranslatePipe } from '@ngx-translate/core';
import { TranslateService } from '@ngx-translate/core';

@Component({
  selector: 'app-offer',
  imports: [ImportsModule, OfferModalComponent, RouterLink, TranslatePipe],
  templateUrl: './offer.component.html',
  styleUrls: ['./offer.component.css']
})
export class OffersComponent {
  activeTab: string = 'mine';
  offers: any[] | null = null;  // "all" offers (received)
  myOffers: any[] | null = null; // "my" pending offers
  offerModalVisible: boolean = false;
  offerIdToEdit: number | null = null;

  acceptDialogVisible: boolean = false;
  offerToAccept: any | null = null;

  refuseDialogVisible: boolean = false;
  offerToRefuse: any | null = null;

  deleteDialogVisible: boolean = false;
  offerToDelete: any | null = null;
  requestToDelete: any | null = null;
  isOwningPrinter: boolean | null = null;

  get currentRequests(): any[] {
    return this.activeTab === 'mine' ? this.myOffers || [] : this.offers || [];
  }

  constructor(
    private offerService: OfferService,
    private router: Router,
    private messageService: MessageService,
    private clipboard: Clipboard,
    private orderService: OrderService,
    private translate: TranslateService
  ) {
    const queryParams = this.router.parseUrl(this.router.url).queryParams;
    this.activeTab = queryParams['tab'] || 'mine';
    this.router.navigate([], { queryParams: { tab: this.activeTab }, queryParamsHandling: 'merge' });

    if (this.activeTab === 'all') {
      this.offerService.getOffers().subscribe((requests: any[]) => {
        this.offers = requests;
      });
    } else if (this.activeTab === 'mine') {
      this.offerService.getMyOffers().subscribe((offers: any[]) => {
        console.log("offers:", offers);
        this.myOffers = offers;
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
            if (this.requestToDelete.offers.length === 0) {
              const requestIndex = this.currentRequests.indexOf(this.requestToDelete);
              if (requestIndex !== -1) {
                this.currentRequests.splice(requestIndex, 1);
              }
            }
          }
        } else {
          console.log("Error deleting offer:", response);
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
    this.offerIdToEdit = offer.id;
    this.offerModalVisible = true;
  }

  cancelOffer(offer: any, request: any): void {
    console.log("Canceling:", offer);
    this.offerToDelete = offer;
    this.requestToDelete = request;
    this.deleteDialogVisible = true;
  }

  showAcceptOffer(offer: any): void {
    this.offerToAccept = offer;
    this.acceptDialogVisible = true;
  }

  confirmAccept(): void {
    console.log("Accepting id:", this.offerToAccept.id);
    this.orderService.createOrder(this.offerToAccept.id).subscribe((response) => {
      if (response.status === 201) {
        this.messageService.add({ severity: 'success', summary: this.translate.instant('global.success'), detail: this.translate.instant('offer.accept_success') });
        this.offerToAccept = null;
        this.acceptDialogVisible = false;

        this.offerService.getMyOffers().subscribe((offers: any[]) => {
          this.myOffers = offers;
        });

        this.offerService.getOffers().subscribe((offers: any[]) => {
          this.offers = offers;
        });
      } else {
        this.messageService.add({ severity: 'error', summary: this.translate.instant('global.error'), detail: this.translate.instant('offer.accept_error') });
      }
    });
  }

  showRefuseOffer(offer: any): void {
    console.log("Rejecting id:", offer.id);

    this.offerToRefuse = offer;
    this.refuseDialogVisible = true;
  }

  onOfferUpdated(offer: any): void {
    console.log("Offer updated from offer list:", offer);
    this.offerIdToEdit = null;
    this.offerService.getMyOffers().subscribe((offers: any[]) => {
      this.myOffers = offers;
    });
  }

  confirmRefuse(): void {
    this.offerService.refuseOffer(this.offerToRefuse.id).subscribe((response) => {
      if (response.status === 200) {
        this.offerToRefuse = null;
        this.refuseDialogVisible = false;

        this.offerService.getMyOffers().subscribe((offers: any[]) => {
          this.myOffers = offers;
        });

        this.offerService.getOffers().subscribe((offers: any[]) => {
          this.offers = offers;
        });
      }
    });
  }
}
