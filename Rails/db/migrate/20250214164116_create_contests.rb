class CreateContests < ActiveRecord::Migration[7.1]
  def change
    create_table :contests do |t|
      t.string :theme, null: false, limit: 30
      t.string :description, limit: 200
      t.integer :submission_limit, null: false, default: 1
      t.datetime :deleted_at
      t.datetime :start_at, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :end_at
    end
  end
end
