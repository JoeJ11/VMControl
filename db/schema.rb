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

ActiveRecord::Schema.define(version: 20151103153644) do

  create_table "cluster_configurations", force: :cascade do |t|
    t.string   "specifier",    limit: 255
    t.integer  "size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "instantiated", limit: 255
  end

  create_table "cluster_templates", force: :cascade do |t|
    t.string   "name",                     limit: 255
    t.string   "image_id",                 limit: 255
    t.string   "flavor_id",                limit: 255
    t.string   "internal_ip",              limit: 255
    t.string   "external_ip",              limit: 255
    t.boolean  "ext_enable"
    t.string   "config_id",                limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cluster_configuration_id"
  end

  add_index "cluster_templates", ["cluster_configuration_id"], name: "index_cluster_templates_on_cluster_configuration_id"

  create_table "courses", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "teacher",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "git_token",    limit: 255
    t.string   "mail_address", limit: 255
    t.integer  "git_id"
    t.string   "public_key",   limit: 255
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",               default: 0, null: false
    t.integer  "attempts",               default: 0, null: false
    t.text     "handler",                            null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "experiments", force: :cascade do |t|
    t.string   "name",                     limit: 255
    t.integer  "cluster_configuration_id"
    t.integer  "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status"
    t.integer  "code_repo_id"
    t.integer  "config_repo_id"
  end

  add_index "experiments", ["cluster_configuration_id"], name: "index_experiments_on_cluster_configuration_id"
  add_index "experiments", ["course_id"], name: "index_experiments_on_course_id"

  create_table "images", force: :cascade do |t|
    t.string   "tenant_id",   limit: 255
    t.string   "instance_id", limit: 255
    t.string   "image_name",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "machines", force: :cascade do |t|
    t.string  "ip_address",               limit: 255
    t.string  "setting",                  limit: 255
    t.integer "status"
    t.integer "student_id"
    t.string  "group",                    limit: 255
    t.string  "specifier",                limit: 255
    t.string  "user_name",                limit: 255
    t.integer "cluster_configuration_id"
    t.integer "progress"
    t.string  "url",                      limit: 255
    t.string  "slaves"
  end

  add_index "machines", ["cluster_configuration_id"], name: "index_machines_on_cluster_configuration_id"
  add_index "machines", ["student_id"], name: "index_machines_on_student_id"

  create_table "students", force: :cascade do |t|
    t.string  "mail_address", limit: 255
    t.string  "public_key",   limit: 255
    t.string  "private_key",  limit: 255
    t.string  "git_token",    limit: 255
    t.integer "git_id"
    t.string  "anonym_id"
  end

end
