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

ActiveRecord::Schema[8.0].define(version: 2025_09_09_142701) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "sleep_records", force: :cascade do |t|
    t.datetime "clock_in", precision: nil
    t.datetime "clock_out", precision: nil
    t.float "duration"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["clock_in"], name: "index_sleep_records_on_clock_in"
    t.index ["duration"], name: "index_sleep_records_on_duration"
    t.index ["user_id"], name: "index_sleep_records_on_user_id"
  end

  create_table "user_followings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "following_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["following_user_id"], name: "index_user_followings_on_following_user_id"
    t.index ["user_id"], name: "index_user_followings_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "sleep_records", "users"
  add_foreign_key "user_followings", "users"
  add_foreign_key "user_followings", "users", column: "following_user_id"
end
