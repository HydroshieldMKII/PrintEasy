# frozen_string_literal: true

module Api
  class PresetController < AuthenticatedController
    def index
      @presets = current_user.presets
      render json: @presets.as_json(
        except: %i[color_id filament_id user_id],
        include: %i[color filament]
      )
    end
  end
end
