# frozen_string_literal: true

module Api
  class ReviewController < AuthenticatedController
    before_action :get_review, only: %i[update destroy]

    def show
      @review = Review.find(params[:id])
      render json: {
        review: review_as_json(@review),
        errors: {}
      }, status: :ok
    end

    def create
      @review = Review.new(review_params_create)
      if @review.save
        render json: {
          review: review_as_json(@review),
          errors: {}
        }, status: :created
      else
        render json: { errors: @review.errors.as_json }, status: :unprocessable_entity
      end
    end

    def update
      if @review.update(review_params)
        render json: {
          review: review_as_json(@review),
          errors: {}
        }, status: :ok
      else
        render json: { errors: @review.errors.as_json }, status: :unprocessable_entity
      end
    end

    def destroy
      if @review.destroy!
        render json: {
          review: review_as_json(@review),
          errors: {}
        }, status: :ok
      else
        render json: { errors: @review.errors.as_json }, status: :unprocessable_entity
      end
    end

    def user
      user_reviews = Review.joins(order: { offer: :printer_user }).where('printer_users.user_id = ?', params[:id])
      render json: {
        reviews: review_as_json(user_reviews),
        errors: {}
      }, status: :ok
    end

    private

    def review_as_json(review)
      review.as_json(
        methods: %i[image_urls], 
        include: { 
          user: { 
            except: %i[country_id], 
            include: { country: {} }, 
            methods: %i[profile_picture_url] 
          } 
        }
      )
    end

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
