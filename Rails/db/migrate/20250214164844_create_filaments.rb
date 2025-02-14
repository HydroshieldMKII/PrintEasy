class CreateFilaments < ActiveRecord::Migration[7.1]
  def change
    create_table :filaments do |t|
      t.string :name, limit: 60, null: false
      t.float :size, null: false
    end
  end
end
