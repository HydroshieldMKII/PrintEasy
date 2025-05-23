# frozen_string_literal: true

class AddCountryToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :country, null: false, foreign_key: true
  end
end
