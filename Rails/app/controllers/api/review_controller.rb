class Api::ReviewController < AuthenticatedController
  before_action :get_review, only: %i[show update destroy]
  before_action :review_params, only: %i[create update]

  def show 
    render json: { review: @review.as_json(except: %i[created_at updated_at], methods: %i[image_url]), errors: {} }, status: :ok
  end

  def create
    @review = Review.new(review_params)
    if @review.save
      render json: { review: @review.as_json(methods: %i[image_url]), errors: {} }, status: :created
    else
      render json: { errors: @review.errors.as_json }, status: :bad_request
    end
  end

  def update
    if @review.update(review_params)
      render json: { review: @review.as_json(methods: %i[image_url]), errors: {} }, status: :ok
    else
      render json: { errors: @review.errors.as_json }, status: :bad_request
    end
  end

  def destroy
    if @review.destroy!
      render json: { review: @review.as_json(), errors: {} }, status: :ok
    else
      render json: { errors: @review.errors.as_json }, status: :bad_request
    end
  end

  private

  def get_review
    @review = current_user.reviews.find(params[:id])
  end

  def review_params
    params.require(:review).permit(:rating, :comment, :image, :order_id)
  end
end