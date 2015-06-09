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

ActiveRecord::Schema.define(version: 20140925025141) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admin_translations", force: :cascade do |t|
    t.integer  "admin_id",     null: false
    t.string   "locale",       null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.text     "profile"
    t.text     "long_profile"
  end

  add_index "admin_translations", ["admin_id"], name: "index_admin_translations_on_admin_id", using: :btree
  add_index "admin_translations", ["locale"], name: "index_admin_translations_on_locale", using: :btree

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "small_picture"
    t.string   "large_picture"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "nickname"
    t.string   "work_place"
    t.string   "work_position"
    t.string   "work_url"
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "comments", force: :cascade do |t|
    t.string   "author"
    t.text     "content"
    t.string   "gravatar_email"
    t.integer  "post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "answer_to_id"
  end

  create_table "dynamic_settings", force: :cascade do |t|
    t.datetime "last_tweet_check"
    t.text     "twitter_consumer_key"
    t.text     "twitter_consumer_secret"
    t.text     "oauth_token"
    t.text     "oauth_token_secret"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "dropbox_session"
  end

  create_table "post_translations", force: :cascade do |t|
    t.integer  "post_id",    null: false
    t.string   "locale",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "title"
    t.text     "content"
  end

  add_index "post_translations", ["locale"], name: "index_post_translations_on_locale", using: :btree
  add_index "post_translations", ["post_id"], name: "index_post_translations_on_post_id", using: :btree

  create_table "posts", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "friendly_id"
    t.string   "main_picture"
    t.boolean  "published"
  end

  create_table "posts_tags", id: false, force: :cascade do |t|
    t.integer "post_id"
    t.integer "tag_id"
  end

  create_table "tag_translations", force: :cascade do |t|
    t.integer  "tag_id",     null: false
    t.string   "locale",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name"
  end

  add_index "tag_translations", ["locale"], name: "index_tag_translations_on_locale", using: :btree
  add_index "tag_translations", ["tag_id"], name: "index_tag_translations_on_tag_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tweets", force: :cascade do |t|
    t.datetime "posted"
    t.text     "content"
    t.text     "twitter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tweets", ["twitter_id"], name: "index_tweets_on_twitter_id", unique: true, using: :btree

end
