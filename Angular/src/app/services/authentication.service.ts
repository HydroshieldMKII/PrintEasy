import { inject, Injectable } from '@angular/core';
import { UserModel } from '../models/user.model';
import { map } from 'rxjs/operators';
import { Observable } from 'rxjs';
import { MessageService } from 'primeng/api';

import { UserCredentialsModel } from '../models/user-credentials.model';
import { ApiRequestService } from './api.service';
import { ApiResponseModel } from '../models/api-response.model';

@Injectable({
    providedIn: 'root'
})
export class AuthService {
    private readonly CURRENT_USER_KEY = 'printeasy.currentUser';
    private _currentUser: UserModel | null = null;
    messageService: MessageService = inject(MessageService);

    get currentUser(): UserModel | null {
        return this._currentUser;
    }

    get isLoggedIn(): boolean {
        return !!this._currentUser;
    }

    constructor(private api: ApiRequestService) {
        const storedCurrentUser = JSON.parse(localStorage.getItem(this.CURRENT_USER_KEY) ?? 'null');

        if (storedCurrentUser) {
            this._currentUser = new UserModel(storedCurrentUser.id, storedCurrentUser.username, storedCurrentUser.country, storedCurrentUser.profilePictureUrl, storedCurrentUser.createdAt, storedCurrentUser.isAdmin);
        }
    }


    private setCurrentUser(user: UserModel | null) {
        this._currentUser = user;

        if (user === null) {
            localStorage.removeItem(this.CURRENT_USER_KEY);
            return;
        } else {
            localStorage.setItem(this.CURRENT_USER_KEY, JSON.stringify(user));
        }
    }

    logIn(providedCredentials: UserCredentialsModel): Observable<ApiResponseModel> {
        const credentials = {
            user: {
                username: providedCredentials.username,
                password: providedCredentials.password
            }
        };

        return this.api.postRequest('users/sign_in', {}, credentials).pipe(
            map(response => {
                if (response.status === 200) {

                    if (!this.isLoggedIn) {
                        this.messageService.add({ severity: 'success', summary: 'Welcome', detail: 'You are now logged in!' });
                        const userData = (response.data as any)?.['user'];

                        this.setCurrentUser(new UserModel(userData?.['id'], userData?.['username'], userData?.['country_name'], userData?.['profile_picture_url'], userData?.['created_at'], userData?.['is_admin']));
                    }
                }
                return response;
            })
        );
    }


    signUp(providedCredentials: UserCredentialsModel): Observable<ApiResponseModel> {
        const credentials = {
            user: {
                username: providedCredentials.username,
                password: providedCredentials.password,
                password_confirmation: providedCredentials.confirmPassword,
                country_id: providedCredentials.countryId
            }
        };
        
        return this.api.postRequest('users', {}, credentials).pipe(
            map(response => {
                // console.log('Sign up response:', response);
                if (response.status === 200) {
                    this.messageService.add({ severity: 'success', summary: 'Account created', detail: 'You are now ready to use the app!' });
                    const userData = (response.data as any)?.['user'];
                    this.setCurrentUser(new UserModel(userData?.['id'], userData?.['username'], userData?.['country_name'], userData?.['created_at'], userData?.["profile_picture_url"], userData?.['is_admin']));
                }
                return response;
            })
        );
    }

    logOut() {
        return this.api.deleteRequest('users/sign_out', {}).pipe(
            map(response => {
                // console.log('Logout response:', response);
                this.setCurrentUser(null);
                this.messageService.add({ severity: 'success', summary: 'Logout', detail: 'You logged out successfully!' });
                return response;
            }),
        );
    }

}