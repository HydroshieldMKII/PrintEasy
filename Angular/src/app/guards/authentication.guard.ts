import { CanActivate, RouterStateSnapshot, Router, ActivatedRouteSnapshot } from '@angular/router';
import { inject, Injectable } from '@angular/core';

@Injectable({
    providedIn: 'root'
})
export class AuthenticationGuard implements CanActivate {
    router: Router = inject(Router);

    canActivate(route: ActivatedRouteSnapshot, state: RouterStateSnapshot): boolean {
        const url: string = state.url;
        const isLoggedIn = localStorage.getItem('printeasy.currentUser') !== 'null';

        console.log('URL:', url);
        console.log('Is logged in:', isLoggedIn);

        if ((url === '/login' || url === '/signup') && isLoggedIn) {
            this.router.navigate(['/']);
            return false;
        }

        if (!isLoggedIn && !(url === '/login' || url === '/signup')) {
            this.router.navigate(['/login']);
            return false;
        }

        return true;
    }
}