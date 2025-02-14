class CreateRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :requests do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, limit: 30, null: false
      t.float :budget
      t.string :comment, limit: 200
      t.date :target_date

      t.timestamps
    end
  end
end
