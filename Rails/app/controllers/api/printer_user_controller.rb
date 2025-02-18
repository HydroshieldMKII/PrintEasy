class Api::PrinterUserController < ApplicationController
    before_action :authenticate_user!

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
end
