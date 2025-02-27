# frozen_string_literal: true

class CreateSubmissions < ActiveRecord::Migration[7.1]
  def change
    create_table :submissions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :contest, null: false, foreign_key: true
      t.string :name, null: false, limit: 30
      t.string :description, limit: 200

      t.timestamps
    end
  end
end
