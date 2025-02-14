class CreatePresetRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :preset_requests do |t|
      t.references :request, null: false, foreign_key: true
      t.references :color, null: false, foreign_key: true
      t.references :filament, null: false, foreign_key: true
    end
  end
end
