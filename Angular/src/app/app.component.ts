import { Component, inject } from '@angular/core';
import { Router, RouterOutlet } from '@angular/router';
import { OnInit } from '@angular/core';
import { BadgeModule } from 'primeng/badge';
import { CommonModule } from '@angular/common';
import { AuthService } from './services/authentication.service';
import { JsonPipe } from '@angular/common';

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
  language: string = 'fr';
  userMenuItems: MenuItem[] = [];

  constructor(
    private primeng: PrimeNG,
    private messageService: MessageService,
    private translate: TranslateService
  ) {
    this.translate.addLangs(['en', 'fr']);
    this.translate.setDefaultLang('fr');
    this.translate.setTranslation('fr', translationFR);
    this.translate.setTranslation('en', translationEn);

    const savedLanguage = localStorage.getItem('language') || 'fr';
    this.translate.use(savedLanguage);
    localStorage.setItem('language', savedLanguage);
    this.language = savedLanguage;

    this.translate.onLangChange.subscribe(() => {
      this.onLanguageChange();
    });
  }

  onLanguageChange() {
    this.items = [
      {
        label: this.translate.instant('global.menu.requests'),
        icon: 'pi pi-inbox',
        command: () => this.router.navigate(['/requests'])
      },
      {
        label: this.translate.instant('global.menu.offers'),
        icon: 'pi pi-tag',
        command: () => this.router.navigate(['/offers'])
      },
      {
        label: this.translate.instant('global.menu.orders'),
        icon: 'pi pi-shopping-cart',
        command: () => this.router.navigate(['/orders'])
      },
      {
        label: this.translate.instant('global.menu.contest'),
        icon: 'pi pi-trophy',
        command: () => this.router.navigate(['/contest'])
      },
    ]

    this.userMenuItems = [
      { label: this.translate.instant('global.menu.profile'), icon: 'pi pi-user', command: () => this.viewProfile() },
      { label: this.translate.instant('global.menu.logout'), icon: 'pi pi-sign-out', command: () => this.logout() }
    ];
  }

  ngOnInit() {
    this.primeng.ripple.set(true);
    this.onLanguageChange();
  }


  navigateToHome() {
    this.router.navigate(['/']);
  }

  switchLanguage() {
    const lang = localStorage.getItem('language');
    if (lang === 'fr') {
      this.translate.use('en');
      localStorage.setItem('language', 'en');
    }
    else {
      this.translate.use('fr');
      localStorage.setItem('language', 'fr');
    }

    this.language = localStorage.getItem('language') || 'fr';
  }

  viewProfile() {
    // Navigate to the profile page
    const userId = this.auth.currentUser?.id;
    if (userId !== undefined) {
      this.router.navigate(['/profile', userId.toString()]);
    }
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
