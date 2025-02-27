# frozen_string_literal: true

class UpdateNameOfFkInOrderStatus < ActiveRecord::Migration[7.1]
  def change
    rename_column :order_status, :status_id, :status_name
  end
end
