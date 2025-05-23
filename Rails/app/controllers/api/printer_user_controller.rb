# frozen_string_literal: true

module Api
  class PrinterUserController < AuthenticatedController
    before_action :set_printer_user, only: %i[show update destroy]

    def index
      @printer_users = current_user.printer_users

      render json: { printer_users: @printer_users.as_json({
                                                             except: %i[user_id printer_id],
                                                             include: {
                                                               printer: {
                                                                 only: %i[id model]
                                                               },
                                                               user: {
                                                                 include: { country: {} }
                                                               }
                                                             },
                                                             methods: %i[last_used can_update]
                                                           }) }, status: :ok
    end

    def show
      render json: @printer_user.as_json({
                                           except: %i[user_id printer_id],
                                           include: {
                                             printer: {
                                               only: %i[id model]
                                             }
                                           }
                                         })
    end

    def create
      @printer_user = current_user.printer_users.new(printer_user_params)

      if @printer_user.save
        render json: { printer_user: @printer_user.as_json({
                                                             except: %i[user_id printer_id],
                                                             include: {
                                                               printer: {
                                                                 only: %i[id model]
                                                               },
                                                               user: {
                                                                 include: { country: {} }
                                                               }
                                                             },
                                                             methods: %i[last_used can_update]
                                                           }) }, status: :created
      else
        render json: { errors: @printer_user.errors.as_json }, status: :unprocessable_entity
      end
    end

    def update
      if @printer_user.update(printer_user_params)
        render json: { printer_user: @printer_user.as_json({
                                                             except: %i[user_id printer_id],
                                                             include: {
                                                               printer: {
                                                                 only: %i[id model]
                                                               },
                                                               user: {
                                                                 include: { country: {} }
                                                               }
                                                             },
                                                             methods: %i[last_used can_update]
                                                           }) }, status: :ok
      else
        render json: { errors: @printer_user.errors.as_json }, status: :unprocessable_entity
      end
    end

    def destroy
      if @printer_user.destroy
        render json: {
          printer_user: @printer_user.as_json(
            except: %i[user_id printer_id],
            include: {
              printer: {
                only: %i[id model]
              }
            }
          )
        }
      else
        render json: { errors: @printer_user.errors.as_json }, status: :unprocessable_entity
      end
    end

    private

    def set_printer_user
      @printer_user = current_user.printer_users.find(params[:id])
    end

    def printer_user_params
      params.require(:printer_user).permit(:printer_id, :acquired_date)
    end
  end
end
