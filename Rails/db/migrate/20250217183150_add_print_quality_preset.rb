# frozen_string_literal: true

class AddPrintQualityPreset < ActiveRecord::Migration[7.1]
  def change
    add_column :presets, :print_quality, :float
  end
end
