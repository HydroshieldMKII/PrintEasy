import { Component, inject } from '@angular/core';
import { Router, RouterOutlet } from '@angular/router';
import { OnInit } from '@angular/core';
import { BadgeModule } from 'primeng/badge';
import { CommonModule } from '@angular/common';

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
    ToastModule, BadgeModule, CommonModule, InputTextModule, Ripple, AvatarModule, Menu
  ],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent implements OnInit {
  router: Router = inject(Router);
  items: MenuItem[] | undefined;

  constructor(
    private primeng: PrimeNG,
    private messageService: MessageService
  ) { }

  ngOnInit() {
    this.primeng.ripple.set(true);

    // Set the items for the menubar
    this.items = [
      {
        label: 'Requests',
        icon: 'pi pi-inbox'
      },
      {
        label: 'Offer',
        icon: 'pi pi-tag'
      },
      {
        label: 'Orders',
        icon: 'pi pi-shopping-cart'
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

  viewProfile() {
    // Navigate to the profile page
    this.router.navigate(['/profile']);
  }

  logout() {
    this.messageService.add({ severity: 'success', summary: 'Logout', detail: 'You logged out successfully!' });
  }
}
