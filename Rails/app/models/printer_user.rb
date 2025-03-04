# frozen_string_literal: true

class PrinterUser < ApplicationRecord
  belongs_to :printer
  belongs_to :user
  has_many :offers
  
  def last_review_image
    # Find completed offers with reviews and images
    completed_offer = offers.joins(order: { review: :images_attachments })
                           .where("reviews.id IS NOT NULL")
                           .order("reviews.created_at DESC")
                           .first
                           
    return nil unless completed_offer && completed_offer.order.review.images.attached?
    
    review = completed_offer.order.review

    image = review.images.first
    return {
      url: Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true),
      review_id: review.id,
      order_id: completed_offer.order.id,
      rating: review.rating,
      title: review.title
    }
  end
end