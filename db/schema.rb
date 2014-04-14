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

ActiveRecord::Schema.define(version: 20131125153912) do

  create_table "contactings", force: true do |t|
    t.string   "token",      null: false
    t.string   "name",       null: false
    t.string   "email",      null: false
    t.string   "subject",    null: false
    t.text     "message"
    t.string   "user_agent"
    t.string   "ip_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contactings", ["token"], name: "index_contactings_on_token", unique: true, using: :btree

  create_table "events", force: true do |t|
    t.string "token",       null: false
    t.string "type",        null: false
    t.date   "date",        null: false
    t.text   "description"
  end

  add_index "events", ["date"], name: "index_events_on_date", using: :btree
  add_index "events", ["token"], name: "index_events_on_token", unique: true, using: :btree
  add_index "events", ["type"], name: "index_events_on_type", using: :btree

  create_table "people", force: true do |t|
    t.string   "token",                                         null: false
    t.string   "name",                                          null: false
    t.text     "description",                                   null: false
    t.date     "date_of_birth",                                 null: false
    t.string   "place_of_birth"
    t.date     "date_of_death"
    t.string   "place_of_death"
    t.text     "alternative_names",                                          array: true
    t.string   "wikipedia_identifier"
    t.integer  "rank",                              default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "wikipedia_image_url",  limit: 1024
    t.text     "wikipedia_about_html"
    t.string   "gnd_identifier"
    t.string   "viaf_identifier"
    t.string   "lccn_identifier"
  end

  add_index "people", ["name"], name: "index_people_on_name", using: :btree
  add_index "people", ["rank"], name: "index_people_on_rank", using: :btree
  add_index "people", ["token"], name: "index_people_on_token", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "login",                           null: false
    t.string   "password_digest",                 null: false
    t.string   "first_name",                      null: false
    t.string   "last_name",                       null: false
    t.boolean  "trashed",         default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "locale",          default: "en"
  end

  add_index "users", ["created_at"], name: "index_users_on_created_at", using: :btree
  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree
  add_index "users", ["trashed"], name: "index_users_on_trashed", using: :btree
  add_index "users", ["updated_at"], name: "index_users_on_updated_at", using: :btree

end
