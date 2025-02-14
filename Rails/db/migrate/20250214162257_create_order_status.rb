class CreateOrderStatus < ActiveRecord::Migration[7.1]
  def change
    create_table :order_statuses do |t|
      t.references :order, null: false, foreign_key: true
      t.references :status, null: false, foreign_key: true

      t.string :comment, limit: 255

      t.timestamps
    end
  end
end
