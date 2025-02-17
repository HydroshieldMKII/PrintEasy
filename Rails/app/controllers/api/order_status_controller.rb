class Api::OrderStatusController < ApplicationController
    before_action :order_status_params, only: %i[create update]

    def show
        wanted_order = Order.find(params[:id])
        if wanted_order.nil?
            render json: { errors: 'Order not found' }, status: :not_found
        end
        if current_user == wanted_order.offer.request.user || current_user == wanted_order.offer.printer_user.user
            @order_status = OrderStatus.where(order: wanted_order)
            render json: { order_status: @order_status.as_json(except: %i[created_at updated_at]) }, status: :ok
        else
            render json: { errors: 'You are not authorized to view this order status' }, status: :unauthorized
        end
    end

    # PUT /order_status
    def update
        @order_status = OrderStatus.find(params[:id])
        if @order_status.order.offer.printer_user.user == current_user
            #TODO : can we change the status of the order?

            if @order_status.update(order_status_params)
                render json: { order_status: @order_status.as_json(except: %i[created_at updated_at]), errors: {} }, status: :ok
            else
                render json: { errors: @order_status.errors.as_json }, status: :bad_request
            end
        else
            render json: { errors: 'You are not authorized to update this order status' }, status: :unauthorized
        end
    end

    def create
        if current_user == Order.find(params[:order_id]).offer.printer_user.user
            # printer owner
            @order_status = OrderStatus.new(order_status_params)
            if @order_status.save
                render json: { order_status: @order_status.as_json(except: %i[created_at updated_at]), errors: {} }, status: :created
            else
                render json: { errors: @order_status.errors.as_json }, status: :bad_request
            end
        elsif current_user == Order.find(params[:order_id]).offer.request.user
            # request owner
            @order_status = OrderStatus.new(order: Order.find(params[:order_id]), status_name: 'Arrived')
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
        #TODO : can we delete the status of the order?
        #TODO : what type of status can be deleted?
    end

    private

    def order_status_params
        params.require(:order_status).permit(:status_name, :comment, :image)
    end

end