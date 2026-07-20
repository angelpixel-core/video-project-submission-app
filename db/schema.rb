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

ActiveRecord::Schema[8.1].define(version: 2026_07_20_143000) do
  create_table "clients", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_clients_on_email", unique: true
  end

  create_table "comments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "author_id", null: false
    t.string "author_type", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.bigint "project_id", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_comments_on_author_type_and_author_id"
    t.index ["project_id"], name: "index_comments_on_project_id"
  end

  create_table "notifications", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "body", null: false
    t.bigint "client_id"
    t.datetime "created_at", null: false
    t.datetime "delivered_at"
    t.string "kind", null: false
    t.bigint "pm_id"
    t.bigint "project_id", null: false
    t.datetime "read_at"
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_notifications_on_client_id"
    t.index ["kind"], name: "index_notifications_on_kind"
    t.index ["pm_id"], name: "index_notifications_on_pm_id"
    t.index ["project_id"], name: "index_notifications_on_project_id"
    t.check_constraint "((`pm_id` is not null) and (`client_id` is null)) or ((`pm_id` is null) and (`client_id` is not null))", name: "notifications_single_recipient"
  end

  create_table "pms", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_pms_on_email", unique: true
  end

  create_table "projects", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "pm_id", null: false
    t.string "raw_footage_url"
    t.string "status", default: "draft", null: false
    t.datetime "updated_at", null: false
    t.string "youtube_url"
    t.index ["client_id"], name: "index_projects_on_client_id"
    t.index ["pm_id"], name: "index_projects_on_pm_id"
    t.index ["status"], name: "index_projects_on_status"
  end

  create_table "video_type_selections", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "project_id", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "updated_at", null: false
    t.bigint "video_type_id", null: false
    t.index ["project_id", "video_type_id"], name: "index_video_type_selections_on_project_and_video_type", unique: true
    t.index ["project_id"], name: "index_video_type_selections_on_project_id"
    t.index ["video_type_id"], name: "index_video_type_selections_on_video_type_id"
  end

  create_table "video_types", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.string "name", null: false
    t.string "output_format", null: false
    t.integer "price_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_video_types_on_name", unique: true
  end

  add_foreign_key "comments", "projects"
  add_foreign_key "notifications", "clients"
  add_foreign_key "notifications", "pms"
  add_foreign_key "notifications", "projects"
  add_foreign_key "projects", "clients"
  add_foreign_key "projects", "pms"
  add_foreign_key "video_type_selections", "projects"
  add_foreign_key "video_type_selections", "video_types"
end
