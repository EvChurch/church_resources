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

ActiveRecord::Schema.define(version: 2019_05_19_222410) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "authors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "category_topics", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "category_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category_id"], name: "index_category_topics_on_category_id"
  end

  create_table "resource_connection_authors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "resource_id", null: false
    t.uuid "author_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_id"], name: "index_resource_connection_authors_on_author_id"
    t.index ["resource_id"], name: "index_resource_connection_authors_on_resource_id"
  end

  create_table "resource_connection_scriptures", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "resource_id", null: false
    t.uuid "scripture_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["resource_id"], name: "index_resource_connection_scriptures_on_resource_id"
    t.index ["scripture_id"], name: "index_resource_connection_scriptures_on_scripture_id"
  end

  create_table "resource_connection_series", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "resource_id", null: false
    t.uuid "series_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["resource_id"], name: "index_resource_connection_series_on_resource_id"
    t.index ["series_id"], name: "index_resource_connection_series_on_series_id"
  end

  create_table "resource_connection_topics", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "resource_id", null: false
    t.uuid "topic_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["resource_id"], name: "index_resource_connection_topics_on_resource_id"
    t.index ["topic_id"], name: "index_resource_connection_topics_on_topic_id"
  end

  create_table "resources", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "type"
    t.string "name"
    t.string "snippet"
    t.text "content"
    t.datetime "published_at"
    t.datetime "featured_at"
    t.string "video_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "scriptures", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "series", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "category_topics", "categories", on_delete: :cascade
  add_foreign_key "resource_connection_authors", "authors", on_delete: :cascade
  add_foreign_key "resource_connection_authors", "resources", on_delete: :cascade
  add_foreign_key "resource_connection_scriptures", "resources", on_delete: :cascade
  add_foreign_key "resource_connection_scriptures", "scriptures", on_delete: :cascade
  add_foreign_key "resource_connection_series", "resources", on_delete: :cascade
  add_foreign_key "resource_connection_series", "series", on_delete: :cascade
  add_foreign_key "resource_connection_topics", "category_topics", column: "topic_id", on_delete: :cascade
  add_foreign_key "resource_connection_topics", "resources", on_delete: :cascade
end
