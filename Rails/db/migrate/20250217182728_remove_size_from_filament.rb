# frozen_string_literal: true

class RemoveSizeFromFilament < ActiveRecord::Migration[7.1]
  def change
    remove_column :filaments, :size
  end
end
