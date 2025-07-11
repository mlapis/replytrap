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

ActiveRecord::Schema[8.0].define(version: 2025_07_06_221353) do
  create_table "conversations", force: :cascade do |t|
    t.string "email_contact"
    t.string "classification"
    t.string "status"
    t.integer "email_account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_account_id"], name: "index_conversations_on_email_account_id"
  end

  create_table "email_accounts", force: :cascade do |t|
    t.string "email"
    t.string "fetch_server"
    t.string "smtp_server"
    t.text "username"
    t.text "password"
    t.boolean "active"
    t.datetime "last_checked_at"
    t.string "status"
    t.text "error_message"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "fetch_protocol", default: "imap", null: false
    t.integer "persona_id"
    t.index ["persona_id"], name: "index_email_accounts_on_persona_id"
    t.index ["user_id"], name: "index_email_accounts_on_user_id"
  end

  create_table "email_messages", force: :cascade do |t|
    t.string "subject"
    t.text "body"
    t.string "direction"
    t.integer "conversation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "message_id"
    t.index ["conversation_id"], name: "index_email_messages_on_conversation_id"
    t.index ["message_id"], name: "index_email_messages_on_message_id", unique: true
  end

  create_table "personas", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_personas_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "conversations", "email_accounts"
  add_foreign_key "email_accounts", "personas"
  add_foreign_key "email_accounts", "users"
  add_foreign_key "email_messages", "conversations"
  add_foreign_key "personas", "users"
end
