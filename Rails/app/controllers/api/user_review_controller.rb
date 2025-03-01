# frozen_string_literal: true

module Api
  class UserReviewController < AuthenticatedController
    def index
      # REVIEW: -> order -> offer -> printer_user -> user
      user_reviews = Review.joins(order: { offer: :printer_user }).where('printer_users.user_id = ?', current_user.id)
      render json: {
        reviews: user_reviews.as_json(
          methods: %i[image_urls],
          include: {
            user: { except: %i[created_at updated_at is_admin] }
          }
        ),
        errors: {}
      }, status: :ok
    end
  end
end
