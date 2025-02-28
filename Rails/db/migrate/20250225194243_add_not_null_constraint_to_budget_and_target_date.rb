# frozen_string_literal: true

class AddNotNullConstraintToBudgetAndTargetDate < ActiveRecord::Migration[8.0]
  def change
    change_column_null :requests, :budget, false
    change_column_null :requests, :target_date, false
    change_column_null :offers, :target_date, false
    change_column_null :users, :username, false
    change_column_null :countries, :name, false
  end
end
