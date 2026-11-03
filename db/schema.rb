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

ActiveRecord::Schema[8.1].define(version: 2026_03_18_120000) do
  create_table "leases", force: :cascade do |t|
    t.integer "unit_id", null: false
    t.integer "tenant_id", null: false
    t.date "start_on", null: false
    t.date "end_on", null: false
    t.string "frequency", default: "annual", null: false
    t.decimal "rent_amount", precision: 12, scale: 2, null: false
    t.decimal "deposit", precision: 12, scale: 2, default: "0.0", null: false
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "ended_on"
    t.index ["tenant_id"], name: "index_leases_on_tenant_id"
    t.index ["unit_id"], name: "index_leases_on_unit_id"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "lease_id", null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.date "paid_on", null: false
    t.string "payment_method", default: "transfer", null: false
    t.string "reference"
    t.string "receipt_no", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "voided_at"
    t.decimal "balance_after", precision: 12, scale: 2
    t.index ["lease_id"], name: "index_payments_on_lease_id"
    t.index ["paid_on"], name: "index_payments_on_paid_on"
    t.index ["receipt_no"], name: "index_payments_on_receipt_no"
  end

  create_table "properties", force: :cascade do |t|
    t.string "name", null: false
    t.string "address", null: false
    t.string "area"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tenants", force: :cascade do |t|
    t.string "full_name", null: false
    t.string "phone"
    t.string "email"
    t.string "next_of_kin"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "units", force: :cascade do |t|
    t.integer "property_id", null: false
    t.string "label", null: false
    t.string "kind", default: "flat", null: false
    t.decimal "listed_rent", precision: 12, scale: 2
    t.string "status", default: "vacant", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id", "label"], name: "index_units_on_property_id_and_label", unique: true
    t.index ["property_id"], name: "index_units_on_property_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "leases", "tenants"
  add_foreign_key "leases", "units"
  add_foreign_key "payments", "leases"
  add_foreign_key "units", "properties"
end
