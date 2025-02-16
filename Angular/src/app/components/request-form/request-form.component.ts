import { Component } from '@angular/core';
import { Route, Router } from '@angular/router';

@Component({
  selector: 'app-request-form',
  imports: [],
  templateUrl: './request-form.component.html',
  styleUrl: './request-form.component.css'
})
export class RequestFormComponent {
  constructor(router: Router) {
    const action = router.url.split('/')[2];
    const id = router.url.split('/')[3];

    if (id === null && action === 'edit') {
      // redirect to home
      router.navigate(['/']);
    }

    if (action === 'edit') {
      // edit request
    } else {
      // create new request
    }
  }
}
