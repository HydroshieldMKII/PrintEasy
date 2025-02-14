class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :offers, null: false, foreign_key: true, index: { unique: true }
    end
  end
end
