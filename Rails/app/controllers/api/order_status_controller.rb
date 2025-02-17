class Api::OrderStatusController < ApplicationController
    before_action :order_status_params

    def show
        wanted_order = Order.find(params[:id])
        if wanted_order.nil?
            render json: { error: 'Order not found' }, status: :not_found
        end
        if current_user == wanted_order.offer.request.user || current_user == wanted_order.offer.printer_user.user
            @order_status = OrderStatus.where(order: wanted_order)
            render json: { order_status: @order_status.as_json(except: %i[order_id created_at updated_at]) }, status: :ok
        else
            render json: { error: 'You are not authorized to view this order status' }, status: :unauthorized
        end
    end

    def update

    end

    def create

    end

    def destroy

    end

    private

    def order_status_params
        params.permit(:id, :status, :comment, :image)
    end

end