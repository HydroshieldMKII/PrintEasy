class CreateLikes < ActiveRecord::Migration[7.1]
  def change
    create_table :likes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :submission, null: false, foreign_key: true
    end

    add_index :likes, [:user_id, :submission_id], unique: true
  end
end
