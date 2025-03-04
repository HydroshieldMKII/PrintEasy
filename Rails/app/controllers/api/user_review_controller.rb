# frozen_string_literal: true

module Api
  class UserReviewController < AuthenticatedController
    def index
      # REVIEW: -> order -> offer -> printer_user -> user
      user_reviews = Review.joins(order: { offer: :printer_user }).where('printer_users.user_id = ?', current_user.id)
      render json: {
        reviews: user_reviews.as_json(
          include: {
            user: {
              except: %i[crountry_id],
              include: {country: {}},
              methods: %i[profile_picture_url]
            }
          },
          methods: %i[image_urls]
        ),
        errors: {}
      }, status: :ok
    end
  end
end
