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

ActiveRecord::Schema[8.1].define(version: 2026_01_31_213638) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "api_usage_logs", force: :cascade do |t|
    t.integer "cost", default: 250
    t.datetime "created_at", null: false
    t.integer "partner_id", null: false
    t.integer "profile_id", null: false
    t.string "request_type"
    t.datetime "updated_at", null: false
    t.index ["partner_id"], name: "index_api_usage_logs_on_partner_id"
    t.index ["profile_id"], name: "index_api_usage_logs_on_profile_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "category"
    t.string "color"
    t.datetime "created_at", null: false
    t.json "meta_data"
    t.string "season"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "outfit_suggestions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.json "item_ids"
    t.boolean "selected", default: false
    t.date "suggested_for_date"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.json "weather_snapshot"
    t.index ["user_id"], name: "index_outfit_suggestions_on_user_id"
  end

  create_table "partners", force: :cascade do |t|
    t.string "api_key"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.string "webhook_url"
    t.index ["api_key"], name: "index_partners_on_api_key", unique: true
  end

  create_table "profiles", force: :cascade do |t|
    t.string "avatar_3d_file_path"
    t.datetime "created_at", null: false
    t.float "height_cm"
    t.boolean "is_public_api", default: true
    t.json "measurements"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.float "weight_kg"
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "password_digest"
    t.integer "role", default: 0
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "api_usage_logs", "partners"
  add_foreign_key "api_usage_logs", "profiles"
  add_foreign_key "items", "users"
  add_foreign_key "outfit_suggestions", "users"
  add_foreign_key "profiles", "users"
end
