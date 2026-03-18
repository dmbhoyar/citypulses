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

ActiveRecord::Schema[8.1].define(version: 2026_03_17_174500) do
  create_table "cities", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "agmarknet_district"
    t.string "agmarknet_market"
    t.string "agmarknet_state"
    t.datetime "created_at", null: false
    t.float "latitude"
    t.float "longitude"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["agmarknet_district"], name: "index_cities_on_agmarknet_district"
    t.index ["agmarknet_market"], name: "index_cities_on_agmarknet_market"
    t.index ["agmarknet_state"], name: "index_cities_on_agmarknet_state"
    t.index ["name"], name: "index_cities_on_name", unique: true
  end

  create_table "farmings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "city_id"
    t.text "content"
    t.datetime "created_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_farmings_on_city_id"
  end

  create_table "job_applications", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.bigint "job_id"
    t.text "message"
    t.string "name"
    t.string "phone"
    t.string "resume_url"
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_job_applications_on_job_id"
  end

  create_table "jobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "category"
    t.bigint "city_id"
    t.string "company"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "external_url"
    t.string "location"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["city_id"], name: "index_jobs_on_city_id"
    t.index ["user_id"], name: "index_jobs_on_user_id"
  end

  create_table "listings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "category"
    t.bigint "city_id"
    t.string "contact_number"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "location"
    t.decimal "price", precision: 12, scale: 2
    t.bigint "shop_id"
    t.string "status", default: "active"
    t.string "subcategory"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["city_id"], name: "index_listings_on_city_id"
    t.index ["shop_id"], name: "index_listings_on_shop_id"
    t.index ["user_id"], name: "index_listings_on_user_id"
  end

  create_table "markets", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "city", null: false
    t.bigint "city_id"
    t.string "commodity"
    t.datetime "created_at", null: false
    t.string "district"
    t.float "latitude"
    t.float "longitude"
    t.decimal "max_price", precision: 12, scale: 2
    t.decimal "min_price", precision: 12, scale: 2
    t.decimal "modal_price", precision: 12, scale: 2
    t.date "price_date"
    t.decimal "rate", precision: 10, scale: 2
    t.string "source_url"
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_markets_on_city_id"
    t.index ["district"], name: "index_markets_on_district"
  end

  create_table "revenues", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "recorded_at"
    t.bigint "shop_id"
    t.string "source"
    t.datetime "updated_at", null: false
    t.index ["shop_id"], name: "index_revenues_on_shop_id"
  end

  create_table "shops", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "address"
    t.bigint "city_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.json "page_config"
    t.string "phone"
    t.string "template"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["city_id"], name: "index_shops_on_city_id"
    t.index ["user_id"], name: "index_shops_on_user_id"
  end

  create_table "subscriptions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.string "provider"
    t.string "provider_id"
    t.bigint "shop_id"
    t.datetime "starts_at"
    t.string "status", default: "pending"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["shop_id"], name: "index_subscriptions_on_shop_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "updates", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "city_id"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "published_at"
    t.string "source_url"
    t.string "title", null: false
    t.string "update_type", default: "general"
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_updates_on_city_id"
    t.index ["update_type"], name: "index_updates_on_update_type"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.text "experience"
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.string "mobile_number", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role", default: "normal", null: false
    t.bigint "shop_id"
    t.datetime "subscription_expires_at"
    t.string "tags"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["shop_id"], name: "index_users_on_shop_id"
  end

  add_foreign_key "farmings", "cities"
  add_foreign_key "job_applications", "jobs"
  add_foreign_key "jobs", "cities"
  add_foreign_key "jobs", "users"
  add_foreign_key "listings", "cities"
  add_foreign_key "listings", "shops"
  add_foreign_key "listings", "users"
  add_foreign_key "markets", "cities"
  add_foreign_key "revenues", "shops"
  add_foreign_key "shops", "cities"
  add_foreign_key "shops", "users"
  add_foreign_key "subscriptions", "shops"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "updates", "cities"
  add_foreign_key "users", "shops"
end
