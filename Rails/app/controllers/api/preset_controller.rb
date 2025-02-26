class Api::PresetController < AuthenticatedController
    def index
        @presets = current_user.presets
        render json: @presets.as_json(
            except: [:color_id, :filament_id, :user_id],
            include: [:color, :filament]
        )
    end
end