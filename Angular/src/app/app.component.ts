import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { OnInit } from '@angular/core';

import { PrimeNG } from 'primeng/config';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent implements OnInit {
  title = 'app';

  constructor(private primeng: PrimeNG) { }
  ngOnInit() {
    this.primeng.ripple.set(true);
  }
}
