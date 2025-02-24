class Api::OrderStatusController < AuthenticatedController
    before_action :order_status_params_update, only: %i[update]
    before_action :order_status_params_create, only: %i[create]

    def show
        #TODO: remove rescue nil and return
        this_status = OrderStatus.find(params[:id]) rescue nil
        if this_status.nil?
            render json: { errors: {order_status: ['Order Status not found']} }, status: :not_found and return
        end

        if current_user == this_status.consumer || current_user == this_status.printer
            render json: { order_status: this_status.as_json(except: %i[created_at updated_at], methods: %i[image_url]), errors: {} }, status: :ok
        else
            render json: { errors: {order_status: ['You are not authorized to view this order status']} }, status: :forbidden
        end
    end

    # PUT /order_status
    def update
        @order_status = OrderStatus.find(params[:id])

        if @order_status.update(order_status_params_update)
            render json: { order_status: @order_status.as_json(methods: %i[image_url]), errors: {} }, status: :ok
        else
            render json: { errors: @order_status.errors.as_json }, status: :bad_request
        end

    rescue OrderStatus::OrderStatusFrozenError => e
        render json: { errors: { order_status: [e.to_s]}.as_json }, status: :bad_request
    end

    def create
        Order.find(order_status_params_create[:order_id])
        
        @order_status = OrderStatus.new(order_status_params_create)
        if @order_status.save
            render json: { order_status: @order_status.as_json(methods: %i[image_url]), errors: {} }, status: :created
        else
            render json: { errors: @order_status.errors.as_json }, status: :bad_request
        end
    end

    def destroy
        @order_status = OrderStatus.find(params[:id])
        if @order_status.destroy!
            render json: { order_status: @order_status.as_json(), errors: {} }, status: :ok
        else
            render json: { errors: @order_status.errors.as_json }, status: :bad_request
        end
    rescue OrderStatus::CannotDestroyStatusError => e
        render json: { errors: { order_status: [e.to_s]}.as_json }, status: :bad_request
    rescue OrderStatus::OrderStatusFrozenError => e
        render json: { errors: { order_status: [e.to_s]}.as_json }, status: :bad_request
    end

    private

    def order_status_params_update
        params.require(:order_status).permit(:comment, :image)
    end

    def order_status_params_create
        params.require(:order_status).permit(:status_name, :comment, :image, :order_id)
    end

end