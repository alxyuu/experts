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

ActiveRecord::Schema.define(version: 2020_06_29_091110) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "members", force: :cascade do |t|
    t.string "name", null: false
    t.string "website_url", null: false
    t.string "short_url"
    t.jsonb "topics", default: [], null: false
    t.index ["topics"], name: "index_members_on_topics", using: :gin
  end

  create_table "relationships", force: :cascade do |t|
    t.bigint "from_id"
    t.bigint "to_id"
    t.index ["from_id", "to_id"], name: "index_relationships_on_from_id_and_to_id", unique: true
    t.index ["from_id"], name: "index_relationships_on_from_id"
    t.index ["to_id"], name: "index_relationships_on_to_id"
  end

  add_foreign_key "relationships", "members", column: "from_id"
  add_foreign_key "relationships", "members", column: "to_id"
end
