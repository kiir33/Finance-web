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

ActiveRecord::Schema[8.1].define(version: 2026_11_14_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "audit_logs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "action"
    t.text "details"
    t.uuid "public_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["public_id"], name: "index_audit_logs_on_public_id", unique: true
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "group_accounts", force: :cascade do |t|
    t.decimal "cash_balance"
    t.decimal "bank_balance"
    t.uuid "public_id"
    t.integer "lock_version"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["public_id"], name: "index_group_accounts_on_public_id", unique: true
  end

  create_table "group_transactions", force: :cascade do |t|
    t.bigint "group_account_id", null: false
    t.decimal "amount"
    t.string "transaction_type"
    t.uuid "public_id"
    t.integer "lock_version"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_account_id"], name: "index_group_transactions_on_group_account_id"
    t.index ["public_id"], name: "index_group_transactions_on_public_id", unique: true
  end

  create_table "loan_repayments", force: :cascade do |t|
    t.bigint "loan_id", null: false
    t.decimal "amount"
    t.uuid "public_id"
    t.integer "lock_version"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["loan_id"], name: "index_loan_repayments_on_loan_id"
    t.index ["public_id"], name: "index_loan_repayments_on_public_id", unique: true
  end

  create_table "loans", force: :cascade do |t|
    t.bigint "member_id", null: false
    t.uuid "public_id"
    t.integer "lock_version"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_loans_on_member_id"
    t.index ["public_id"], name: "index_loans_on_public_id", unique: true
  end

  create_table "members", force: :cascade do |t|
    t.string "member_id"
    t.string "name"
    t.string "phone_number"
    t.string "address"
    t.bigint "user_id", null: false
    t.uuid "public_id"
    t.integer "lock_version"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_members_on_member_id", unique: true
    t.index ["public_id"], name: "index_members_on_public_id", unique: true
    t.index ["user_id"], name: "index_members_on_user_id"
  end

  create_table "savings_accounts", force: :cascade do |t|
    t.bigint "member_id", null: false
    t.uuid "public_id"
    t.integer "lock_version"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_savings_accounts_on_member_id"
    t.index ["public_id"], name: "index_savings_accounts_on_public_id", unique: true
  end

  create_table "savings_transactions", force: :cascade do |t|
    t.bigint "savings_account_id", null: false
    t.decimal "amount"
    t.string "transaction_type"
    t.uuid "public_id"
    t.integer "lock_version"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["public_id"], name: "index_savings_transactions_on_public_id", unique: true
    t.index ["savings_account_id"], name: "index_savings_transactions_on_savings_account_id"
  end

  create_table "sync_outboxes", force: :cascade do |t|
    t.string "record_type"
    t.string "record_id"
    t.string "public_id"
    t.datetime "changed_at"
    t.boolean "deleted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["changed_at"], name: "index_sync_outboxes_on_changed_at"
    t.index ["record_type"], name: "index_sync_outboxes_on_record_type"
  end

  create_table "sync_states", force: :cascade do |t|
    t.string "device_id"
    t.datetime "last_synced_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id"], name: "index_sync_states_on_device_id", unique: true
  end

  create_table "system_configs", force: :cascade do |t|
    t.string "config_key"
    t.string "config_value"
    t.string "config_type"
    t.string "description"
    t.integer "lock_version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "public_id"
    t.datetime "deleted_at"
    t.index ["config_key"], name: "index_system_configs_on_config_key", unique: true
    t.index ["config_type"], name: "index_system_configs_on_config_type"
    t.index ["deleted_at"], name: "index_system_configs_on_deleted_at"
  end

  create_table "token_blocklists", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exp"], name: "index_token_blocklists_on_exp"
    t.index ["jti"], name: "index_token_blocklists_on_jti", unique: true
    t.index ["user_id"], name: "index_token_blocklists_on_user_id"
  end

  create_table "user_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token_digest", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_user_sessions_on_expires_at"
    t.index ["token_digest"], name: "index_user_sessions_on_token_digest", unique: true
    t.index ["user_id", "created_at"], name: "index_user_sessions_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_user_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.integer "role"
    t.uuid "public_id"
    t.integer "lock_version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["public_id"], name: "index_users_on_public_id", unique: true
  end

  add_foreign_key "audit_logs", "users"
  add_foreign_key "group_transactions", "group_accounts"
  add_foreign_key "loan_repayments", "loans"
  add_foreign_key "loans", "members"
  add_foreign_key "members", "users"
  add_foreign_key "savings_accounts", "members"
  add_foreign_key "savings_transactions", "savings_accounts"
  add_foreign_key "token_blocklists", "users"
  add_foreign_key "user_sessions", "users"
end
