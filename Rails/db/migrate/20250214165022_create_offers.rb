# frozen_string_literal: true

class CreateOffers < ActiveRecord::Migration[7.1]
  def change
    create_table :offers do |t|
      t.references :request, null: false, foreign_key: true
      t.references :printer_user, null: false, foreign_key: true
      t.references :color, null: false, foreign_key: true
      t.references :filament, null: false, foreign_key: true
      t.float :price, null: false
      t.date :target_date

      t.timestamps
    end
  end
end
