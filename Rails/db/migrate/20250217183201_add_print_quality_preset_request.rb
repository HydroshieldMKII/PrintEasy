# frozen_string_literal: true

class AddPrintQualityPresetRequest < ActiveRecord::Migration[7.1]
  def change
    add_column :preset_requests, :print_quality, :float
  end
end
