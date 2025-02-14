class CreatePrinterUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :printer_users do |t|
      t.references :printer, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.date :acquired_date, null: false
    end
  end
end
