# frozen_string_literal: true

class CreateColors < ActiveRecord::Migration[7.1]
  def change
    create_table :colors do |t|
      t.string :name, limit: 30, null: false
    end
  end
end
