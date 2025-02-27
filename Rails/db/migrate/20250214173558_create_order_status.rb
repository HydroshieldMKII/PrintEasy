# frozen_string_literal: true

class CreateOrderStatus < ActiveRecord::Migration[7.1]
  def change
    create_table :order_status do |t|
      t.references :order, null: false, foreign_key: true

      t.references :status, null: false, type: :string, foreign_key: { to_table: :status, primary_key: :name }

      t.string :comment, limit: 255

      t.timestamps
    end
  end
end
