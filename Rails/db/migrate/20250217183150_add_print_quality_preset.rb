class AddPrintQualityPreset < ActiveRecord::Migration[7.1]
  def change
    add_column :presets, :print_quality, :string
  end
end
