# frozen_string_literal: true

class CreateReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true, index: { unique: true }

      t.integer :rating, null: false, limit: 1
      t.string :title, null: false, limit: 30
      t.string :description, limit: 200

      t.timestamps
    end
  end
end
