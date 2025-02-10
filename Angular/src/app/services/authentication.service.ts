import { Injectable } from '@angular/core';
import { UserModel } from '../models/user.model';
import { map } from 'rxjs/operators';
import { Observable } from 'rxjs';

import { UserCredentialsModel } from '../models/user-credentials.model';
import { ApiRequestService } from './api.service';
import { RequestResponseModel } from '../models/request-response.model';

@Injectable({
    providedIn: 'root'
})
export class AuthService {
    private readonly CURRENT_USER_KEY = 'printeasy.currentUser';
    private _currentUser: UserModel | null = null;

    get currentUser(): UserModel | null {
        return this._currentUser;
    }

    get isLoggedIn(): boolean {
        return !!this._currentUser;
    }

    constructor(private api: ApiRequestService) {
        const storedCurrentUser = JSON.parse(localStorage.getItem(this.CURRENT_USER_KEY) ?? 'null');

        if (storedCurrentUser) {
            this._currentUser = new UserModel(storedCurrentUser.email);
        }
    }


    private setCurrentUser(user: UserModel | null) {
        this._currentUser = user;
        localStorage.setItem(this.CURRENT_USER_KEY, JSON.stringify(user));
    }

    logIn(credentials: UserCredentialsModel): Observable<RequestResponseModel | boolean> {

        return this.api.postRequest('/users/login', credentials).pipe(
            map(response => {
                if (response?.status === 200) {
                    // this.setCurrentUser(new UserModel(credentials.username));

                    return true;
                } else {
                    console.log('Login failed. Errors:', response?.errors);
                    return response;
                }
            })
        );

    }

    signUp(credentials: UserCredentialsModel): Observable<boolean> {

        console.log({ credentials })

        return this.api.postRequest('/users/sign_up', credentials).pipe(
            map(result => {
                if (result?.status === 200) {
                    // this.setCurrentUser(new UserModel(credentials.username));

                    return true;
                } else {
                    return false;
                }
            })
        );

    }

    logOut() {
        this.setCurrentUser(null);
    }

}