import { inject, Injectable } from "@angular/core";
import { ReviewApi, ReviewModel } from "../models/review.model";

import { ApiRequestService } from "./api.service";
import { ApiResponseModel } from "../models/api-response.model";

import { map } from "rxjs/operators";
import { Observable } from "rxjs";

@Injectable({
    providedIn: "root"
})
export class ReviewService {
    constructor(private api: ApiRequestService) {}

    getReview(id: number): Observable<ReviewModel | ApiResponseModel> {
        return this.api.getRequest(`api/review/${id}`).pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    return ReviewModel.fromAPI(response.data.review);
                }
                return response;
            })
        );
    }

    createReview(review: FormData): Observable<ReviewModel | ApiResponseModel> {
        return this.api.postRequest("api/review", {}, review).pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 201) {
                    return ReviewModel.fromAPI(response.data.review);
                }
                return response;
            })
        );
    }

    updateReview(id: number, review: FormData): Observable<ReviewModel | ApiResponseModel> {
        return this.api.patchRequest(`api/review/${id}`, {}, review).pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    return ReviewModel.fromAPI(response.data.review);
                }
                return response;
            })
        );
    }

    deleteReview(id: number): Observable<ReviewModel | ApiResponseModel> {
        return this.api.deleteRequest(`api/review/${id}`).pipe(
            map((response: ApiResponseModel) => {
                if (response.status === 200) {
                    return ReviewModel.fromAPI(response.data.review);
                }
                return response;
            })
        );
    }
}