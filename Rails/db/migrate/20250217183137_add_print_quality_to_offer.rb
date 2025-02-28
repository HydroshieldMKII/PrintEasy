# frozen_string_literal: true

class AddPrintQualityToOffer < ActiveRecord::Migration[7.1]
  def change
    add_column :offers, :print_quality, :float
  end
end
