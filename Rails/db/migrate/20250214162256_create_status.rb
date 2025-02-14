class CreateStatus < ActiveRecord::Migration[7.1]
  def change
    create_table :status do |t|
      t.string :name, null: false, limit: 255
    end
  end
end
