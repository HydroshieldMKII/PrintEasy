# frozen_string_literal: true

module Api
  class ReviewController < AuthenticatedController
    before_action :get_review, only: %i[update destroy]
    before_action :review_params, only: %i[update]
    before_action :review_params_create, only: %i[create]

    def show
      @review = Review.find(params[:id])
      render json: { review: @review.as_json(except: %i[created_at updated_at], include: { user: { except: %i[created_at updated_at is_admin] } }, methods: %i[image_urls]), errors: {} },
             status: :ok
    end

    def create
      @review = Review.new(review_params_create)
      if @review.save
        render json: { review: @review.as_json(methods: %i[image_urls], include: { user: { except: %i[created_at updated_at is_admin] } }), errors: {} },
               status: :created
      else
        render json: { errors: @review.errors.as_json }, status: :bad_request
      end
    end

    def update
      if @review.update(review_params)
        render json: { review: @review.as_json(methods: %i[image_urls], include: { user: { except: %i[created_at updated_at is_admin] } }), errors: {} },
               status: :ok
      else
        render json: { errors: @review.errors.as_json }, status: :bad_request
      end
    end

    def destroy
      if @review.destroy!
        render json: { review: @review.as_json(methods: %i[image_urls], include: { user: { except: %i[created_at updated_at is_admin] } }), errors: {} },
               status: :ok
      else
        render json: { errors: @review.errors.as_json }, status: :bad_request
      end
    end

    private

    def get_review
      user_reviews = Review.where(user_id: current_user.id)
      @review = user_reviews.find(params[:id])
    end

    def review_params_create
      params.require(:review).permit(:rating, :description, :order_id, :title, images: [])
    end

    def review_params
      params.require(:review).permit(:rating, :description, :title, images: [])
    end
  end
end
