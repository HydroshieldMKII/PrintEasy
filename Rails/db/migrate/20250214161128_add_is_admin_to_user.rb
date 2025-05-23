# frozen_string_literal: true

class AddIsAdminToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :is_admin, :boolean, null: false, default: false
  end
end
