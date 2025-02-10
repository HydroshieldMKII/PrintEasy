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

    logIn(providedCredentials: UserCredentialsModel): Observable<RequestResponseModel> {
        const credentials = {
            user: {
                username: providedCredentials.username,
                password: providedCredentials.password
            }
        };

        return this.api.postRequest('users/login', {}, credentials).pipe(
            map(response => {
                console.log('Login response:', response);
                return response;
            })
        );
    }


    signUp(providedCredentials: UserCredentialsModel): Observable<RequestResponseModel> {
        const credentials = {
            user: {
                username: providedCredentials.username,
                password: providedCredentials.password,
                password_confirmation: providedCredentials.confirmPassword
            }
        };
        return this.api.postRequest('users/sign_up', {}, credentials).pipe(
            map(response => {
                console.log('Sign up response:', response);
                return response;
            })
        );
    }

    logOut() {
        this.setCurrentUser(null);
    }

}