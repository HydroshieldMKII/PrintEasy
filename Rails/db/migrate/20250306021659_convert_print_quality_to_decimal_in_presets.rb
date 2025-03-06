# frozen_string_literal: true

class ConvertPrintQualityToDecimalInPresets < ActiveRecord::Migration[8.0]
  def change
    change_column :presets, :print_quality, :decimal, precision: 4, scale: 2, null: false
  end
end
