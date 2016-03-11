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

ActiveRecord::Schema.define(version: 20160310144056) do

  create_table "weather_readings", force: :cascade do |t|
    t.datetime "reading_at"
    t.decimal  "temperature",                   precision: 10
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.string   "location",          limit: 255
    t.integer  "wind_speed",        limit: 4
    t.string   "wind_direction",    limit: 255
    t.decimal  "pressure",                      precision: 10
    t.decimal  "relative_humidity",             precision: 10
    t.integer  "dew_point",         limit: 4
  end

  add_index "weather_readings", ["reading_at"], name: "index_weather_readings_on_reading_at", using: :btree

end
