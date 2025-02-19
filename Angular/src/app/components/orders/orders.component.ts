import { Component } from '@angular/core';
import { ImportsModule } from '../../../imports';


@Component({
  selector: 'app-orders',
  imports: [ImportsModule],
  templateUrl: './orders.component.html',
  styleUrl: './orders.component.css'
})
export class OrdersComponent {

  constructor() {
  }
}
