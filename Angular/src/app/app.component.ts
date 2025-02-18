import { Component, inject } from '@angular/core';
import { Router, RouterOutlet } from '@angular/router';
import { OnInit } from '@angular/core';
import { BadgeModule } from 'primeng/badge';
import { CommonModule } from '@angular/common';
import { AuthService } from './services/authentication.service';

import {
  TranslateService,
  TranslatePipe,
  TranslateDirective
} from "@ngx-translate/core";
import translationFR from '../../public/i18n/fr.json';
import translationEn from '../../public/i18n/en.json';

import { PrimeNG } from 'primeng/config';
import { Menu } from 'primeng/menu';
import { MenuItem } from 'primeng/api';
import { ButtonModule } from 'primeng/button';
import { Menubar, MenubarModule } from 'primeng/menubar';
import { ToastModule } from 'primeng/toast';
import { MessageService } from 'primeng/api';
import { InputTextModule } from 'primeng/inputtext';
import { Ripple } from 'primeng/ripple';
import { AvatarModule } from 'primeng/avatar';

@Component({
  selector: 'app-root',
  imports: [
    RouterOutlet, Menubar, MenubarModule, ButtonModule,
    ToastModule, BadgeModule, CommonModule, InputTextModule,
    Ripple, AvatarModule, Menu
  ],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent implements OnInit {
  router: Router = inject(Router);
  auth: AuthService = inject(AuthService);
  items: MenuItem[] | undefined;

  constructor(
    private primeng: PrimeNG,
    private messageService: MessageService,
    private translate: TranslateService
  ) {
    this.translate.addLangs(['en', 'fr']);
    this.translate.setDefaultLang('fr');
    this.translate.setTranslation('fr', translationFR);
    this.translate.setTranslation('en', translationEn);

    this.translate.use('fr');
    localStorage.setItem('language', 'fr');
  }

  ngOnInit() {
    this.primeng.ripple.set(true);

    // Set the items for the menubar
    this.items = [
      {
        label: 'Requests',
        icon: 'pi pi-inbox',
        command: () => this.router.navigate(['/requests'])
      },
      {
        label: 'Offer',
        icon: 'pi pi-tag',
        command: () => this.router.navigate(['/offers'])
      },
      {
        label: 'Orders',
        icon: 'pi pi-shopping-cart',
        command: () => this.router.navigate(['/orders'])
      },
      {
        label: 'Contests',
        icon: 'pi pi-trophy'
      },
    ]
  }

  userMenuItems = [
    { label: 'My Profile', icon: 'pi pi-user', command: () => this.viewProfile() },
    { label: 'Logout', icon: 'pi pi-sign-out', command: () => this.logout() }
  ];

  navigateToHome() {
    this.router.navigate(['/']);
  }

  viewProfile() {
    // Navigate to the profile page
    this.router.navigate(['/profile']);
  }

  logout() {
    if (!this.auth.isLoggedIn) {
      return;
    }

    this.auth.logOut().subscribe((response) => {
      if (response.status === 200 || response.status === 401) {
        this.router.navigate(['/login']);
      }
    });
  }

  isLoggedIn() {
    return this.auth.isLoggedIn;
  }

  getUsername() {
    return this.auth.currentUser?.username;
  }
}
