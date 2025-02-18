class Api::OrderStatusController < ApplicationController
    before_action :order_status_params_update, only: %i[update]
    before_action :order_status_params_create, only: %i[create]

    def show
        this_status = OrderStatus.find(params[:id])
        if this_status.nil?
            render json: { errors: 'Order Status not found' }, status: :not_found
        end
        if current_user == this_status.consumer || current_user == this_status.printer
            render json: { order_status: this_status.as_json(except: %i[created_at updated_at]) }, status: :ok
        else
            render json: { errors: 'You are not authorized to view this order status' }, status: :unauthorized
        end
    end

    # PUT /order_status
    def update
        @order_status = OrderStatus.find(params[:id])
        if @order_status.nil?
            render json: { errors: 'Order status not found' }, status: :not_found
        end
        if @order_status.printer == current_user
            if @order_status.update(order_status_params_update)
                render json: { order_status: @order_status.as_json(except: %i[created_at updated_at]), errors: {} }, status: :ok
            else
                render json: { errors: @order_status.errors.as_json }, status: :bad_request
            end
        else
            render json: { errors: 'You are not authorized to update this order status' }, status: :unauthorized
        end
    end

    def create
        this_order = Order.find(order_status_params_create[:order_id])
        if this_order.nil?
            render json: { errors: 'Order not found' }, status: :not_found
        end
        if current_user == this_order.printer
            # printer owner
            
            if order_status_params_create[:status_name] == 'Accepted'
              render json: { errors: 'You cannot create an Accepted status' }, status: :bad_request
            end
            
            @order_status = OrderStatus.new(order_status_params_create)
            if @order_status.save
                render json: { order_status: @order_status.as_json(except: %i[created_at updated_at]), errors: {} }, status: :created
            else
                render json: { errors: @order_status.errors.as_json }, status: :bad_request
            end
        elsif current_user == this_order.consumer
            # request owner
            @order_status = OrderStatus.new(order: this_order, status_name: 'Arrived')
            if @order_status.save
                render json: { order_status: @order_status.as_json(except: %i[created_at updated_at]), errors: {} }, status: :created
            else
                render json: { errors: @order_status.errors.as_json }, status: :bad_request
            end
        else
            render json: { errors: 'You are not authorized to create a new status for this order' }, status: :unauthorized
        end
    end

    def destroy
        @order_status = OrderStatus.find(params[:id])
        if @order_status.nil?
            render json: { errors: 'Order status not found' }, status: :not_found
        end
        if @order_status.printer == current_user
            @order_status.destroy!
            render json: { order_status: @order_status.as_json(except: %i[created_at updated_at]), errors: {} }, status: :ok
        else
            render json: { errors: 'You are not authorized to delete this order status' }, status: :unauthorized
        end
    rescue OrderStatus::CannotDestroyStatusError => e
        render json: { errors: e.as_json }, status: :bad_request
    end

    private

    def order_status_params_update
        params.require(:order_status).permit(:comment, :image)
    end

    def order_status_params_create
        params.require(:order_status).permit(:status_name, :comment, :image, :order_id)
    end

end