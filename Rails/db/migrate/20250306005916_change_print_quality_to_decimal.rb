class ChangePrintQualityToDecimal < ActiveRecord::Migration[8.0]
  def change
    change_column :offers, :print_quality, :decimal, precision: 4, scale: 2, null: false

    change_column :preset_requests, :print_quality, :decimal, precision: 4, scale: 2, null: false
  end
end
