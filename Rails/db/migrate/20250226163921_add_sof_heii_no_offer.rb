# frozen_string_literal: true

class AddSofHeiiNoOffer < ActiveRecord::Migration[8.0]
  def change
    add_column :offers, :cancelled_at, :datetime, default: nil
  end
end
