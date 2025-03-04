# frozen_string_literal: true

module Api
  class PrinterUserController < AuthenticatedController
    def index
      @printer_users = PrinterUser.where(user_id: current_user.id)
      render json: @printer_users.as_json({
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
        render json: @printer_user.as_json({
                                             except: %i[user_id printer_id],
                                             include: {
                                               printer: {
                                                 only: %i[id model]
                                               }
                                             }
                                           })
      else
        render json: { errors: @printer_user.errors.as_json }, status: :unprocessable_entity
      end
    end

    def update
      @printer_user.printer_users.find_by(params[:id])

      if @printer_user.update(printer_user_params)
        render json: @printer_user.as_json({
                                              except: %i[user_id printer_id],
                                              include: {
                                                printer: {
                                                  only: %i[id model]
                                                }
                                              }
                                            })
      else 
        render json: { errors: @printer_user.errors.as_json }, status: :unprocessable_entity
      end
    end

    def destroy
      @printer_user = current_user.printer_users(params[:id])

      if @printer_user.destroy
        render json: { printer_user: @printer_user.as_json(
          except: %i[user_id printer_id],
          include: {
            printer: {
              only: %i[id model]
            }
          }
        ) }
      else
        render json: { errors: @printer_user.errors.as_json }, status: :unprocessable_entity
      end
    end

    private

    def printer_user_params
      params.require(:printer_user).permit(:printer_id, :acquired_date)
    end
  end
end
