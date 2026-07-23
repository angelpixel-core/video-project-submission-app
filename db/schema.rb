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

ActiveRecord::Schema[8.1].define(version: 2026_07_23_122000) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
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

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "accounts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "role", null: false
    t.datetime "updated_at", null: false
    t.index ["email", "role"], name: "index_accounts_on_email_and_role", unique: true
    t.index ["role"], name: "index_accounts_on_role"
  end

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
    t.bigint "author_account_id"
    t.bigint "project_id", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_comments_on_author_type_and_author_id"
    t.index ["author_account_id"], name: "index_comments_on_author_account_id"
    t.index ["project_id"], name: "index_comments_on_project_id"
  end

  create_table "notifications", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "body", null: false
    t.bigint "client_id"
    t.bigint "account_id"
    t.datetime "created_at", null: false
    t.datetime "delivered_at"
    t.string "kind", null: false
    t.bigint "pm_id"
    t.bigint "project_id", null: false
    t.datetime "read_at"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_notifications_on_account_id"
    t.index ["client_id"], name: "index_notifications_on_client_id"
    t.index ["kind"], name: "index_notifications_on_kind"
    t.index ["pm_id"], name: "index_notifications_on_pm_id"
    t.index ["project_id"], name: "index_notifications_on_project_id"
    t.check_constraint "((`pm_id` is not null) and (`client_id` is null)) or ((`pm_id` is null) and (`client_id` is not null))", name: "notifications_single_recipient"
  end

  create_table "payment_attempts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error_message"
    t.string "idempotency_key", null: false
    t.bigint "payment_id", null: false
    t.string "provider", default: "fake", null: false
    t.string "provider_reference"
    t.json "request_payload"
    t.json "response_payload"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["idempotency_key"], name: "index_payment_attempts_on_idempotency_key", unique: true
    t.index ["payment_id", "status"], name: "index_payment_attempts_on_payment_id_and_status"
    t.index ["payment_id"], name: "index_payment_attempts_on_payment_id"
    t.index ["provider_reference"], name: "index_payment_attempts_on_provider_reference", unique: true
  end

  create_table "payment_invoice_delivery_intents", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "attempts_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.text "last_error"
    t.bigint "payment_id", null: false
    t.datetime "processed_at"
    t.datetime "scheduled_at", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_id"], name: "index_payment_invoice_delivery_intents_on_payment_id", unique: true
  end

  create_table "payment_notification_intents", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "attempts_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "event_type", null: false
    t.string "from_status", null: false
    t.text "last_error"
    t.json "payload", null: false
    t.bigint "payment_id", null: false
    t.datetime "processed_at"
    t.bigint "project_id", null: false
    t.datetime "scheduled_at"
    t.string "status", default: "pending", null: false
    t.string "to_status", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_id", "event_type"], name: "index_payment_notification_intents_on_payment_and_event_type", unique: true
    t.index ["payment_id"], name: "index_payment_notification_intents_on_payment_id"
    t.index ["project_id"], name: "index_payment_notification_intents_on_project_id"
    t.index ["status", "scheduled_at"], name: "index_payment_notification_intents_on_status_and_scheduled_at"
  end

  create_table "payment_webhook_event_attempts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.datetime "created_at", null: false
    t.text "error_message"
    t.datetime "finished_at"
    t.bigint "payment_webhook_event_id", null: false
    t.datetime "started_at", null: false
    t.string "status", default: "started", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_webhook_event_id", "attempt_number"], name: "index_payment_webhook_event_attempts_on_event_and_number", unique: true
    t.index ["payment_webhook_event_id", "status"], name: "index_payment_webhook_event_attempts_on_event_and_status"
    t.index ["payment_webhook_event_id"], name: "idx_on_payment_webhook_event_id_8977d48d0c"
  end

  create_table "payment_webhook_events", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error_message"
    t.string "event_type", null: false
    t.datetime "last_attempted_at"
    t.datetime "last_failure_at"
    t.text "last_failure_message"
    t.json "payload", null: false
    t.bigint "payment_id"
    t.datetime "processed_at"
    t.integer "processing_attempts_count", default: 0, null: false
    t.bigint "project_id"
    t.string "provider", null: false
    t.string "provider_event_id", null: false
    t.datetime "received_at", null: false
    t.string "signature"
    t.string "status", default: "received", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_id", "provider_event_id"], name: "index_payment_webhook_events_on_payment_and_provider_event_id", unique: true
    t.index ["payment_id"], name: "index_payment_webhook_events_on_payment_id"
    t.index ["project_id", "status"], name: "index_payment_webhook_events_on_project_id_and_status"
    t.index ["project_id"], name: "index_payment_webhook_events_on_project_id"
    t.index ["provider", "provider_event_id"], name: "index_payment_webhook_events_on_provider_and_event_id", unique: true
    t.index ["provider"], name: "index_payment_webhook_events_on_provider"
    t.index ["status"], name: "index_payment_webhook_events_on_status"
  end

  create_table "payments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "amount_cents", default: 0, null: false
    t.datetime "canceled_at"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "currency", default: "USD", null: false
    t.datetime "failed_at"
    t.string "idempotency_key", null: false
    t.datetime "invoice_emailed_at"
    t.datetime "invoice_generated_at"
    t.string "invoice_number"
    t.bigint "project_id", null: false
    t.string "provider", default: "fake", null: false
    t.string "provider_reference"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["idempotency_key"], name: "index_payments_on_idempotency_key", unique: true
    t.index ["invoice_number"], name: "index_payments_on_invoice_number", unique: true
    t.index ["project_id", "status"], name: "index_payments_on_project_id_and_status"
    t.index ["project_id"], name: "index_payments_on_project_id"
    t.index ["provider_reference"], name: "index_payments_on_provider_reference", unique: true
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
    t.bigint "client_account_id"
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "pm_id", null: false
    t.bigint "pm_account_id"
    t.json "raw_footage_metadata"
    t.string "raw_footage_url"
    t.string "status", default: "draft", null: false
    t.datetime "updated_at", null: false
    t.string "youtube_url"
    t.index ["client_account_id"], name: "index_projects_on_client_account_id"
    t.index ["client_id"], name: "index_projects_on_client_id"
    t.index ["pm_account_id"], name: "index_projects_on_pm_account_id"
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "comments", "accounts", column: "author_account_id"
  add_foreign_key "comments", "projects"
  add_foreign_key "notifications", "accounts", column: "account_id"
  add_foreign_key "notifications", "clients"
  add_foreign_key "notifications", "pms"
  add_foreign_key "notifications", "projects"
  add_foreign_key "payment_attempts", "payments"
  add_foreign_key "payment_invoice_delivery_intents", "payments"
  add_foreign_key "payment_notification_intents", "payments"
  add_foreign_key "payment_notification_intents", "projects"
  add_foreign_key "payment_webhook_event_attempts", "payment_webhook_events"
  add_foreign_key "payment_webhook_events", "payments"
  add_foreign_key "payment_webhook_events", "projects"
  add_foreign_key "payments", "projects"
  add_foreign_key "projects", "accounts", column: "client_account_id"
  add_foreign_key "projects", "accounts", column: "pm_account_id"
  add_foreign_key "projects", "accounts", column: "client_id"
  add_foreign_key "projects", "accounts", column: "pm_id"
  add_foreign_key "video_type_selections", "projects"
  add_foreign_key "video_type_selections", "video_types"
end
