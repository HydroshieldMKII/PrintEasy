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
import { OrderModel } from '../../models/order.model';
import { OfferModel } from '../../models/offer.model';
import { ApiResponseModel } from '../../models/api-response.model';
import { RequestOfferModel } from '../../models/request-offer.model';

@Component({
  selector: 'app-offer',
  imports: [ImportsModule, OfferModalComponent, RouterLink, TranslatePipe],
  templateUrl: './offer.component.html',
  styleUrls: ['./offer.component.css']
})
export class OffersComponent {
  activeTab: string = 'mine';
  offers: RequestOfferModel[] | null = null;  // "all" offers (received)
  myOffers: RequestOfferModel[] | null = null; // "my" pending offers
  offerModalVisible: boolean = false;
  offerIdToEdit: number | null = null;

  acceptDialogVisible: boolean = false;
  offerToAccept: OfferModel | null = null;

  refuseDialogVisible: boolean = false;
  offerToRefuse: OfferModel | null = null;

  deleteDialogVisible: boolean = false;
  offerToDelete: OfferModel | null = null;
  requestToDelete: RequestOfferModel | null = null;
  isOwningPrinter: boolean | null = null;

  get currentRequests(): RequestOfferModel[] {
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
      this.offerService.getOffers().subscribe((requests: RequestOfferModel[] | ApiResponseModel) => {
        if (requests instanceof ApiResponseModel) {
          console.log("Error getting my offers:", requests);
          return;
        }

        console.log("all offers:", requests);
        this.offers = requests;
      });
    } else if (this.activeTab === 'mine') {
      this.offerService.getMyOffers().subscribe((response) => {
        console.log("my offers loaded:", response);
        if (response instanceof ApiResponseModel) {
          console.log("Error getting my offers:", response);
          return;
        }

        console.log("my offers:", response);
        this.myOffers = response as RequestOfferModel[];
      });
    }
  }

  onTabChange(tab: string): void {
    this.activeTab = tab;
    this.router.navigate([], { queryParams: { tab: this.activeTab }, queryParamsHandling: 'merge' });
    if (this.activeTab === 'all' && !this.offers) {
      this.offerService.getOffers().subscribe((requests: RequestOfferModel[] | ApiResponseModel) => {
        if (requests instanceof ApiResponseModel) {
          console.log("Error getting my offers:", requests);
          return;
        }
        this.offers = requests;
      });
    }
    if (this.activeTab === 'mine' && !this.myOffers) {
      this.offerService.getMyOffers().subscribe((response) => {
        if (response instanceof ApiResponseModel) {
          console.log("Error getting my offers:", response);
          return;
        }
        this.myOffers = response as RequestOfferModel[];
      });
    }
  }

  downloadRequest(downloadUrl: string): void {
    window.open(downloadUrl, '_blank');
  }

  showDeleteDialog(offer: OfferModel): void {
    this.offerToDelete = offer;
    this.deleteDialogVisible = true;
  }

  confirmDelete(): void {
    if (this.offerToDelete !== null && this.requestToDelete !== null) {
      this.offerService.deleteOffer(this.offerToDelete.id).subscribe((response) => {
        if (response.status === 200 && this.requestToDelete !== null) {
          this.requestToDelete.offers = this.requestToDelete.offers.filter((offer: OfferModel) => offer !== this.offerToDelete);

          console.log("Offer deleted:", response);
          console.log("Request:", this.requestToDelete);

          if (this.requestToDelete && this.requestToDelete.offers.length === 0) {
            this.myOffers = this.myOffers?.filter(request => request !== this.requestToDelete) || null;
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

  cancelOffer(offer: OfferModel, request: any): void {
    console.log("Canceling:", offer);
    this.offerToDelete = offer;
    this.requestToDelete = request;
    this.deleteDialogVisible = true;
  }

  showAcceptOffer(offer: OfferModel): void {
    this.offerToAccept = offer;
    this.acceptDialogVisible = true;
  }

  confirmAccept(): void {
    console.log("Accepting id:", this.offerToAccept?.id);
    if (!this.offerToAccept?.id) return;

    this.orderService.createOrder(this.offerToAccept.id).subscribe((response: ApiResponseModel | OrderModel) => {
      if (response instanceof OrderModel) {
        this.messageService.add({ severity: 'success', summary: this.translate.instant('global.success'), detail: this.translate.instant('offer.accept_success') });
        this.offerToAccept = null;
        this.acceptDialogVisible = false;

        this.offerService.getMyOffers().subscribe((offers: RequestOfferModel[] | ApiResponseModel) => {
          if (offers instanceof ApiResponseModel) {
            console.log("Error getting my offers:", offers);
            return;
          }
          this.myOffers = offers;
        });

        this.offerService.getOffers().subscribe((offers: RequestOfferModel[] | ApiResponseModel) => {
          if (offers instanceof ApiResponseModel) {
            console.log("Error getting my offers:", offers);
            return;
          }
          this.offers = offers as unknown as RequestOfferModel[];
        });
      } else {
        this.messageService.add({ severity: 'error', summary: this.translate.instant('global.error'), detail: this.translate.instant('offer.accept_error') });
      }
    });
  }

  showRefuseOffer(offer: OfferModel): void {
    console.log("Rejecting id:", offer.id);

    this.offerToRefuse = offer;
    this.refuseDialogVisible = true;
  }

  onOfferUpdated(updated: boolean): void {
    console.log("Offer updated from offer list:", updated);
    this.offerIdToEdit = null;
    this.offerService.getMyOffers().subscribe((offers) => {
      if (offers instanceof ApiResponseModel) {
        console.log("Error getting my offers:", offers);
        return;
      }
      this.myOffers = offers as RequestOfferModel[];
    });
  }

  confirmRefuse(): void {
    if (!this.offerToRefuse?.id) return;

    this.offerService.refuseOffer(this.offerToRefuse.id).subscribe((response) => {
      if (response.status === 200) {
        this.offerToRefuse = null;
        this.refuseDialogVisible = false;

        this.offerService.getMyOffers().subscribe((response) => {
          if (response instanceof ApiResponseModel) {
            console.log("Error getting my offers:", response);
            return;
          }
          this.myOffers = response as RequestOfferModel[];
        });

        this.offerService.getOffers().subscribe((offers: RequestOfferModel[] | ApiResponseModel) => {
          if (offers instanceof ApiResponseModel) {
            console.log("Error getting my offers:", offers);
            return;
          }
          this.offers = offers;
        });
      }
    });
  }
}
