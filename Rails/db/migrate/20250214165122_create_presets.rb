# frozen_string_literal: true

class CreatePresets < ActiveRecord::Migration[7.1]
  def change
    create_table :presets do |t|
      t.references :color, null: false, foreign_key: true
      t.references :filament, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
    end
  end
end
