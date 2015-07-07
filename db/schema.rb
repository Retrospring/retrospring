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

ActiveRecord::Schema.define(version: 20150704072402) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "answers", force: :cascade do |t|
    t.text     "content"
    t.integer  "question_id"
    t.integer  "comment_count",  default: 0, null: false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "smile_count",    default: 0, null: false
    t.integer  "application_id"
  end

  add_index "answers", ["user_id", "created_at"], name: "index_answers_on_user_id_and_created_at", using: :btree

  create_table "application_metrics", force: :cascade do |t|
    t.integer  "application_id"
    t.string   "req_path"
    t.string   "req_params"
    t.string   "req_method"
    t.integer  "res_timespent"
    t.integer  "db_time"
    t.integer  "db_calls"
    t.integer  "res_status"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "comment_smiles", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "comment_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "application_id"
  end

  add_index "comment_smiles", ["comment_id"], name: "index_comment_smiles_on_comment_id", using: :btree
  add_index "comment_smiles", ["user_id", "comment_id"], name: "index_comment_smiles_on_user_id_and_comment_id", unique: true, using: :btree
  add_index "comment_smiles", ["user_id"], name: "index_comment_smiles_on_user_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.string   "content"
    t.integer  "answer_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "smile_count",    default: 0, null: false
    t.integer  "application_id"
  end

  add_index "comments", ["user_id", "created_at"], name: "index_comments_on_user_id_and_created_at", using: :btree

  create_table "group_members", force: :cascade do |t|
    t.integer  "group_id",   null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_members", ["group_id", "user_id"], name: "index_group_members_on_group_id_and_user_id", unique: true, using: :btree
  add_index "group_members", ["group_id"], name: "index_group_members_on_group_id", using: :btree
  add_index "group_members", ["user_id"], name: "index_group_members_on_user_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.integer  "user_id",                     null: false
    t.string   "name"
    t.string   "display_name"
    t.boolean  "private",      default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups", ["name"], name: "index_groups_on_name", using: :btree
  add_index "groups", ["user_id", "name"], name: "index_groups_on_user_id_and_name", unique: true, using: :btree
  add_index "groups", ["user_id"], name: "index_groups_on_user_id", using: :btree

  create_table "inboxes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "question_id"
    t.boolean  "new"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "moderation_comments", force: :cascade do |t|
    t.integer  "report_id"
    t.integer  "user_id"
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "moderation_comments", ["user_id", "created_at"], name: "index_moderation_comments_on_user_id_and_created_at", using: :btree

  create_table "moderation_votes", force: :cascade do |t|
    t.integer  "report_id",                  null: false
    t.integer  "user_id",                    null: false
    t.boolean  "upvote",     default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "moderation_votes", ["report_id"], name: "index_moderation_votes_on_report_id", using: :btree
  add_index "moderation_votes", ["user_id", "report_id"], name: "index_moderation_votes_on_user_id_and_report_id", unique: true, using: :btree
  add_index "moderation_votes", ["user_id"], name: "index_moderation_votes_on_user_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.string   "target_type"
    t.integer  "target_id"
    t.integer  "recipient_id"
    t.boolean  "new"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",                              null: false
    t.string   "uid",                               null: false
    t.string   "secret",                            null: false
    t.text     "redirect_uri",                      null: false
    t.string   "scopes",            default: "",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "description"
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.integer  "crop_x"
    t.integer  "crop_y"
    t.integer  "crop_w"
    t.integer  "crop_h"
    t.boolean  "icon_processing"
    t.string   "homepage",          default: ""
    t.boolean  "deleted",           default: false
  end

  add_index "oauth_applications", ["name"], name: "index_oauth_applications_on_name", unique: true, using: :btree
  add_index "oauth_applications", ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type", using: :btree
  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "questions", force: :cascade do |t|
    t.string   "content"
    t.boolean  "author_is_anonymous"
    t.string   "author_name"
    t.string   "author_email"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "answer_count",        default: 0, null: false
    t.integer  "application_id"
  end

  add_index "questions", ["user_id", "created_at"], name: "index_questions_on_user_id_and_created_at", using: :btree

  create_table "relationships", force: :cascade do |t|
    t.integer  "source_id"
    t.integer  "target_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationships", ["source_id", "target_id"], name: "index_relationships_on_source_id_and_target_id", unique: true, using: :btree
  add_index "relationships", ["source_id"], name: "index_relationships_on_source_id", using: :btree
  add_index "relationships", ["target_id"], name: "index_relationships_on_target_id", using: :btree

  create_table "reports", force: :cascade do |t|
    t.string   "type",                       null: false
    t.integer  "target_id",                  null: false
    t.integer  "user_id",                    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deleted",    default: false
    t.string   "reason"
  end

  create_table "services", force: :cascade do |t|
    t.string   "type",          null: false
    t.integer  "user_id",       null: false
    t.string   "uid"
    t.string   "access_token"
    t.string   "access_secret"
    t.string   "nickname"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "smiles", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "answer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "application_id"
  end

  add_index "smiles", ["answer_id"], name: "index_smiles_on_answer_id", using: :btree
  add_index "smiles", ["user_id", "answer_id"], name: "index_smiles_on_user_id_and_answer_id", unique: true, using: :btree
  add_index "smiles", ["user_id"], name: "index_smiles_on_user_id", using: :btree

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "user_id",                   null: false
    t.integer  "answer_id",                 null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.boolean  "is_active",  default: true
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                             default: "",    null: false
    t.string   "encrypted_password",                default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "screen_name"
    t.integer  "friend_count",                      default: 0,     null: false
    t.integer  "follower_count",                    default: 0,     null: false
    t.integer  "asked_count",                       default: 0,     null: false
    t.integer  "answered_count",                    default: 0,     null: false
    t.integer  "commented_count",                   default: 0,     null: false
    t.string   "display_name"
    t.integer  "smiled_count",                      default: 0,     null: false
    t.boolean  "admin",                             default: false, null: false
    t.string   "motivation_header",                 default: "",    null: false
    t.string   "website",                           default: "",    null: false
    t.string   "location",                          default: "",    null: false
    t.text     "bio",                               default: "",    null: false
    t.boolean  "moderator",                         default: false, null: false
    t.string   "profile_picture_file_name"
    t.string   "profile_picture_content_type"
    t.integer  "profile_picture_file_size"
    t.datetime "profile_picture_updated_at"
    t.boolean  "profile_picture_processing"
    t.integer  "crop_x"
    t.integer  "crop_y"
    t.integer  "crop_w"
    t.integer  "crop_h"
    t.boolean  "supporter",                         default: false
    t.boolean  "privacy_allow_anonymous_questions", default: true
    t.boolean  "privacy_allow_public_timeline",     default: true
    t.boolean  "privacy_allow_stranger_answers",    default: true
    t.boolean  "privacy_show_in_search",            default: true
    t.boolean  "permanently_banned",                default: false
    t.boolean  "blogger",                           default: false
    t.boolean  "contributor",                       default: false
    t.string   "ban_reason"
    t.datetime "banned_until"
    t.integer  "comment_smiled_count",              default: 0,     null: false
    t.string   "profile_header_file_name"
    t.string   "profile_header_content_type"
    t.integer  "profile_header_file_size"
    t.datetime "profile_header_updated_at"
    t.boolean  "profile_header_processing"
    t.integer  "crop_h_x"
    t.integer  "crop_h_y"
    t.integer  "crop_h_w"
    t.integer  "crop_h_h"
    t.string   "locale",                            default: "en"
    t.boolean  "translator",                        default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["screen_name"], name: "index_users_on_screen_name", unique: true, using: :btree

end
