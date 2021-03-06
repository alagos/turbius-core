# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151016204714) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "cities", force: :cascade do |t|
    t.string    "name"
    t.string    "city"
    t.string    "full_address"
    t.string    "province"
    t.geography "lonlat",       limit: {:srid=>4326, :type=>"point", :geographic=>true}
    t.datetime  "created_at",                                                            null: false
    t.datetime  "updated_at",                                                            null: false
  end

  create_table "itineraries", force: :cascade do |t|
    t.datetime "arrival_date"
    t.datetime "departure_date"
    t.string   "arrival_station",   limit: 255
    t.string   "departure_station", limit: 255
    t.string   "seat_type",         limit: 255
    t.integer  "free_seats"
    t.integer  "total_seats"
    t.integer  "fare"
    t.integer  "trip_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "itineraries", ["trip_id"], name: "index_itineraries_on_trip_id", using: :btree

  create_table "trips", force: :cascade do |t|
    t.string   "origin",      limit: 255
    t.string   "destination", limit: 255
    t.boolean  "available",               default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      limit: 255, null: false
    t.integer  "item_id",                    null: false
    t.string   "event",          limit: 255, null: false
    t.string   "whodunnit",      limit: 255
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
