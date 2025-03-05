class AddUniqueToOffersAndPresets < ActiveRecord::Migration[8.0]
  def change
    add_index :offers, [:request_id, :printer_user_id, :color_id, :filament_id, :print_quality], unique: true
    
    add_index :presets, [:user_id, :filament_id, :color_id, :print_quality], unique: true
  end
end
