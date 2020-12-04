# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_12_04_233101) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "color"
    t.float "min"
    t.float "max"
    t.float "avg"
    t.float "onepercent"
    t.float "percentile97"
    t.string "display_name"
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "apis", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "apis_benches", force: :cascade do |t|
    t.integer "bench_id"
    t.integer "api_id"
    t.jsonb "fps"
    t.jsonb "frametime"
    t.jsonb "full_fps"
    t.jsonb "full_frametime"
    t.jsonb "bar"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "benches", force: :cascade do |t|
    t.string "name"
    t.string "youtubeid"
    t.integer "computer_id"
    t.boolean "published"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.jsonb "totalbar"
    t.text "description"
    t.jsonb "totalcpu"
    t.integer "compare_to"
    t.index ["slug"], name: "index_benches_on_slug", unique: true
  end

  create_table "benches_games", force: :cascade do |t|
    t.integer "game_id"
    t.integer "bench_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "fps"
    t.jsonb "frametime"
    t.jsonb "full_fps"
    t.jsonb "full_frametime"
    t.jsonb "bar"
    t.jsonb "cpu"
    t.jsonb "gpu"
    t.integer "min"
    t.integer "max"
    t.jsonb "avgcpu"
  end

  create_table "computers", force: :cascade do |t|
    t.string "cpu"
    t.string "gpu"
    t.string "ram"
    t.string "memory"
    t.string "os"
    t.string "kernel"
    t.string "driver"
    t.integer "user_id"
    t.integer "log_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "steamid"
    t.string "source"
    t.string "image_url"
    t.string "slug"
    t.string "steam_type"
    t.integer "lutris_id"
    t.index ["slug"], name: "index_games_on_slug", unique: true
  end

  create_table "inputs", force: :cascade do |t|
    t.integer "type_id"
    t.integer "bench_id"
    t.float "fps"
    t.float "frametime"
    t.float "cpu"
    t.float "gpu"
    t.string "color"
    t.string "driver"
    t.integer "benches_game_id"
    t.integer "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "variation_id"
    t.integer "log_id"
    t.bigint "pos"
    t.string "name"
    t.integer "apis_bench_id"
    t.integer "api_id"
  end

  create_table "logs", force: :cascade do |t|
    t.jsonb "fps"
    t.jsonb "frametime"
    t.jsonb "bar"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "user_id"
    t.integer "game_id"
    t.integer "compare_to"
    t.integer "max"
    t.integer "min"
    t.text "title"
    t.text "text"
    t.jsonb "cpu"
    t.jsonb "cpuavg"
  end

  create_table "types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "provider"
    t.string "uid"
    t.string "image"
    t.string "username"
    t.boolean "admin"
    t.boolean "online"
    t.string "url"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "variations", force: :cascade do |t|
    t.string "name"
    t.integer "type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
end
