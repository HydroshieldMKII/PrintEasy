class AddPrintQualityPresetRequest < ActiveRecord::Migration[7.1]
  def change
    add_column :preset_requests, :print_quality, :string
  end
end
