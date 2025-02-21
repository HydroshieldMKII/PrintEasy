class AddUniqueIndexToPresetRequests < ActiveRecord::Migration[7.1]
  def change
    add_index :preset_requests, [:request_id, :color_id, :filament_id, :printer_id, :print_quality],
              unique: true, name: 'index_preset_requests_uniqueness'
  end
end
