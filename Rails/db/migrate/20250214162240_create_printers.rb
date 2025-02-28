# frozen_string_literal: true

class CreatePrinters < ActiveRecord::Migration[7.1]
  def change
    create_table :printers do |t|
      t.string :model, null: false
    end
  end
end
