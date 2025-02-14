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

ActiveRecord::Schema[7.1].define(version: 2025_02_14_173555) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "colors", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", limit: 30, null: false
  end

  create_table "countries", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "filaments", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "type", limit: 60, null: false
    t.float "size", null: false
  end

  create_table "offers", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "request_id", null: false
    t.bigint "printer_user_id", null: false
    t.bigint "color_id", null: false
    t.bigint "filament_id", null: false
    t.float "price", null: false
    t.date "target_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["color_id"], name: "index_offers_on_color_id"
    t.index ["filament_id"], name: "index_offers_on_filament_id"
    t.index ["printer_user_id"], name: "index_offers_on_printer_user_id"
    t.index ["request_id"], name: "index_offers_on_request_id"
  end

  create_table "preset_requests", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "color_id", null: false
    t.bigint "filament_id", null: false
    t.index ["color_id"], name: "index_preset_requests_on_color_id"
    t.index ["filament_id"], name: "index_preset_requests_on_filament_id"
  end

  create_table "presets", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "color_id", null: false
    t.bigint "filament_id", null: false
    t.bigint "user_id", null: false
    t.index ["color_id"], name: "index_presets_on_color_id"
    t.index ["filament_id"], name: "index_presets_on_filament_id"
    t.index ["user_id"], name: "index_presets_on_user_id"
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

  create_table "requests", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "preset_request_id", null: false
    t.bigint "user_id", null: false
    t.string "name", limit: 30, null: false
    t.float "budget"
    t.string "comment", limit: 200
    t.date "target_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["preset_request_id"], name: "index_requests_on_preset_request_id"
    t.index ["user_id"], name: "index_requests_on_user_id"
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "offers", "colors"
  add_foreign_key "offers", "filaments"
  add_foreign_key "offers", "printer_users"
  add_foreign_key "offers", "requests"
  add_foreign_key "preset_requests", "colors"
  add_foreign_key "preset_requests", "filaments"
  add_foreign_key "presets", "colors"
  add_foreign_key "presets", "filaments"
  add_foreign_key "presets", "users"
  add_foreign_key "printer_users", "printers"
  add_foreign_key "printer_users", "users"
  add_foreign_key "requests", "preset_requests"
  add_foreign_key "requests", "users"
  add_foreign_key "users", "countries"
end
