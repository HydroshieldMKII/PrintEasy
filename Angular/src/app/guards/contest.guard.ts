import { RouterStateSnapshot, Router, ActivatedRouteSnapshot, CanActivateChild } from '@angular/router';
import { inject, Injectable } from '@angular/core';
import { AuthService } from '../services/authentication.service';

@Injectable({
    providedIn: 'root',
})
export class ContestGuard implements CanActivateChild {
    authService: AuthService = inject(AuthService);
    
    constructor(private router: Router) {}

    canActivateChild(route: ActivatedRouteSnapshot, state: RouterStateSnapshot): boolean {
        const url: string = state.url;
    
        console.log('URL:', url);
        console.log('Route:', route);
        console.log("authService.currentUser", this.authService.currentUser);
    
        const contestEditPattern = /^\/contest\/\d+$/;
    
        if ((url === '/contest/new' || contestEditPattern.test(url)) && !this.authService.currentUser?.isAdmin) {
            this.router.navigate(['/']);
            return false;
        }
    
        return true;
    }
}
