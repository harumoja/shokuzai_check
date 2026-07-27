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

ActiveRecord::Schema[8.1].define(version: 2026_07_27_012412) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "babyfood_ingredients", force: :cascade do |t|
    t.bigint "babyfood_id", null: false
    t.datetime "created_at", null: false
    t.bigint "ingredient_id", null: false
    t.datetime "updated_at", null: false
    t.index ["babyfood_id", "ingredient_id"], name: "index_babyfood_ingredients_on_food_and_ingredient", unique: true
    t.index ["babyfood_id"], name: "index_babyfood_ingredients_on_babyfood_id"
    t.index ["ingredient_id"], name: "index_babyfood_ingredients_on_ingredient_id"
  end

  create_table "babyfoods", force: :cascade do |t|
    t.string "amazon_url"
    t.datetime "created_at", null: false
    t.string "image_url"
    t.boolean "is_active", default: true, null: false
    t.string "manufacturer", null: false
    t.string "name", null: false
    t.string "rakuten_url"
    t.string "stage", null: false
    t.datetime "updated_at", null: false
    t.index ["is_active", "stage"], name: "index_babyfoods_for_display"
    t.index ["manufacturer", "name"], name: "index_babyfoods_on_manufacturer_and_name", unique: true
  end

  create_table "ingredients", force: :cascade do |t|
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.boolean "is_active", default: true, null: false
    t.string "name", null: false
    t.integer "sort_order", default: 0, null: false
    t.string "stage", null: false
    t.datetime "updated_at", null: false
    t.index ["is_active", "category", "stage", "sort_order"], name: "index_ingredients_for_display"
    t.index ["name"], name: "index_ingredients_on_name", unique: true
  end

  add_foreign_key "babyfood_ingredients", "babyfoods"
  add_foreign_key "babyfood_ingredients", "ingredients"
end
