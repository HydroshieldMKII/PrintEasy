class CreateStatus < ActiveRecord::Migration[7.1]
  def change
    create_table :status, id: false, primary_key: :name do |t|
      t.string :name, null: false, limit: 255, primary_key: true
    end
  end
end
