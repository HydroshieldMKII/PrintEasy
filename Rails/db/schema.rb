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

ActiveRecord::Schema[7.1].define(version: 2025_02_14_165218) do
  create_table "contests", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "theme", limit: 30, null: false
    t.string "description", limit: 200
    t.integer "submission_limit", default: 1, null: false
    t.datetime "deleted_at"
    t.datetime "start_at"
    t.datetime "end_at"
  end

  create_table "countries", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "likes", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "submission_id", null: false
    t.index ["submission_id"], name: "index_likes_on_submission_id"
    t.index ["user_id", "submission_id"], name: "index_likes_on_user_id_and_submission_id", unique: true
    t.index ["user_id"], name: "index_likes_on_user_id"
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

  create_table "submissions", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "contest_id", null: false
    t.string "name", limit: 30, null: false
    t.string "description", limit: 200
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contest_id"], name: "index_submissions_on_contest_id"
    t.index ["user_id"], name: "index_submissions_on_user_id"
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

  add_foreign_key "likes", "submissions"
  add_foreign_key "likes", "users"
  add_foreign_key "printer_users", "printers"
  add_foreign_key "printer_users", "users"
  add_foreign_key "submissions", "contests"
  add_foreign_key "submissions", "users"
  add_foreign_key "users", "countries"
end
