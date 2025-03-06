# frozen_string_literal: true

module Api
  class OrderStatusController < AuthenticatedController
    before_action :find_order_status, only: %i[show update destroy]

    def show
      if current_user == @order_status.consumer || current_user == @order_status.printer
        render json: {
          order_status: @order_status.as_json(except: %i[created_at updated_at], methods: %i[image_url]),
          errors: {}
        }, status: :ok
      else
        render json: {
          errors: {
            order_status: ['You are not authorized to view this order status']
          }
        }, status: :forbidden
      end
    end

    # PUT /order_status
    def update
      if @order_status.update(order_status_params_update)
        render json: { order_status: @order_status.as_json(methods: %i[image_url]), errors: {} }, status: :ok
      else
        render json: { errors: @order_status.errors.as_json }, status: :unprocessable_entity
      end
    end

    def create
      @order_status = OrderStatus.new(order_status_params_create)
      if @order_status.save
        render json: { order_status: @order_status.as_json(methods: %i[image_url]), errors: {} }, status: :created
      else
        render json: { errors: @order_status.errors.as_json }, status: :unprocessable_entity
      end
    end

    def destroy
      if @order_status.destroy
        render json: { order_status: @order_status.as_json, errors: {} }, status: :ok
      else
        render json: { errors: @order_status.errors.as_json }, status: :unprocessable_entity
      end
    end

    private

    def order_status_params_update
      params.require(:order_status).permit(:comment, :image)
    end

    def order_status_params_create
      params.require(:order_status).permit(:status_name, :comment, :image, :order_id)
    end

    def find_order_status
      @order_status = OrderStatus.find(params[:id])
    end
  end
end
