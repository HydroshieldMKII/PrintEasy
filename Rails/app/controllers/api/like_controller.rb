# frozen_string_literal: true

module Api
  class LikeController < AuthenticatedController
    def index
      @likes = current_user.likes

      render json: { likes: @likes, errors: {} }, status: :ok
    end

    def create
      @like = Like.new(like_params)
      current_user.likes << @like

      if @like.save
        render json: { like: @like, errors: {} }, status: :created
      else
        render json: { errors: @like.errors.as_json }, status: :unprocessable_entity
      end
    end

    def destroy
      @like = current_user.likes.find(params[:id])
      if @like.destroy
        render json: { like: @like, errors: {} }, status: :ok
      else
        render json: { errors: @like.errors.as_json }, status: :unprocessable_entity
      end
    end

    private

    def like_params
      params.require(:like).permit(:user_id, :submission_id)
    end
  end
end
