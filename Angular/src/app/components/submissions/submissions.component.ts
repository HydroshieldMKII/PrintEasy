import { Component } from '@angular/core';

import { ImportsModule } from '../../../imports';

import { SubmissionService } from '../../services/submission.service';

@Component({
  selector: 'app-submissions',
  imports: [ImportsModule],
  templateUrl: './submissions.component.html',
  styleUrl: './submissions.component.css'
})
export class SubmissionsComponent {
  products: any[];

  responsiveOptions: any[] | undefined;

  productCardStyle = {
    background: 'var(--surface-card)',
    'border-radius': '12px',
    padding: '1rem',
    transition: 'all 0.3s ease-in-out',
    'border': '1px solid red',
  };

  constructor(private submissionService: SubmissionService) {
    this.products = this.submissionService.getProductsData();

    this.responsiveOptions = [
      {
        breakpoint: '1400px',
        numVisible: 2,
        numScroll: 1,
      },
      {
        breakpoint: '1199px',
        numVisible: 3,
        numScroll: 1,
      },
      {
        breakpoint: '767px',
        numVisible: 2,
        numScroll: 1,
      },
      {
        breakpoint: '575px',
        numVisible: 1,
        numScroll: 1,
      },
    ];
  }

  getSeverity(status: string) {
    switch (status) {
      case 'INSTOCK':
        return 'success';
      case 'LOWSTOCK':
        return 'warn';
      case 'OUTOFSTOCK':
        return 'danger';
      default:
        return undefined;
    }
  }



  submissions = [
    {
      name: 'Utilisateur 1',
      submissions: [
        { title: 'Projet A', image: '/root/PrintEasy/Rails/test/fixtures/files/chicken_bagel.jpg', likes: 120 },
        { title: 'Projet B', image: '/root/PrintEasy/Rails/test/fixtures/files/chicken_bagel.jpg', likes: 95 },
        { title: 'Projet C', image: '/root/PrintEasy/Rails/test/fixtures/files/chicken_bagel.jpg', likes: 150 },
        { title: 'Projet D', image: '/root/PrintEasy/Rails/test/fixtures/files/chicken_bagel.jpg', likes: 180 },
        { title: 'Projet E', image: '/root/PrintEasy/Rails/test/fixtures/files/chicken_bagel.jpg', likes: 200 }
      ]
    },
    {
      name: 'Utilisateur 2',
      submissions: [
        { title: 'Projet X', image: '/root/PrintEasy/Rails/test/fixtures/files/chicken_bagel.jpg', likes: 200 },
        { title: 'Projet Y', image: '/root/PrintEasy/Rails/test/fixtures/files/chicken_bagel.jpg', likes: 180 },
        { title: 'Projet Z', image: '/root/PrintEasy/Rails/test/fixtures/files/chicken_bagel.jpg', likes: 230 }
      ]
    }
  ];
}