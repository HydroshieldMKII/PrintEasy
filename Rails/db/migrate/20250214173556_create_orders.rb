# frozen_string_literal: true

class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :offer, null: false, foreign_key: true, index: { unique: true }
    end
  end
end
