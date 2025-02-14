# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_02_14_162254) do
  create_table "countries", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "printer_users", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "printer_id", null: false
    t.bigint "user_id", null: false
    t.date "acquired_date", null: false
    t.index ["printer_id"], name: "index_printer_users_on_printer_id"
    t.index ["user_id"], name: "index_printer_users_on_user_id"
  end

  create_table "printers", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "model", null: false
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.bigint "country_id", null: false
    t.boolean "is_admin", default: false, null: false
    t.index ["country_id"], name: "index_users_on_country_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "printer_users", "printers"
  add_foreign_key "printer_users", "users"
  add_foreign_key "users", "countries"
end
