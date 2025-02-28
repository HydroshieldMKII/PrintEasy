# frozen_string_literal: true

class AddNullToPrintQualityTables < ActiveRecord::Migration[8.0]
  def change
    change_column_null :offers, :print_quality, false
    change_column_null :presets, :print_quality, false
    change_column_null :preset_requests, :print_quality, false
  end
end
