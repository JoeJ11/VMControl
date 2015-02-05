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

ActiveRecord::Schema.define(version: 20150205125535) do

  create_table "machines", force: true do |t|
    t.string  "ip_address"
    t.string  "setting"
    t.integer "status"
    t.integer "student_id"
    t.string  "group"
    t.string  "specifier"
  end

  add_index "machines", ["student_id"], name: "index_machines_on_student_id"

  create_table "students", force: true do |t|
    t.string "xuetang_id"
    t.string "mail_address"
    t.string "public_key"
  end

end
