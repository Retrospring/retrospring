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

ActiveRecord::Schema.define(version: 2020_04_25_163011) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "announcements", force: :cascade do |t|
    t.text "content", null: false
    t.string "link_text"
    t.string "link_href"
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_announcements_on_user_id"
  end

  create_table "answers", id: :serial, force: :cascade do |t|
    t.text "content"
    t.integer "question_id"
    t.integer "comment_count", default: 0, null: false
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "smile_count", default: 0, null: false
    t.index ["user_id", "created_at"], name: "index_answers_on_user_id_and_created_at"
  end

  create_table "comment_smiles", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "comment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comment_id"], name: "index_comment_smiles_on_comment_id"
    t.index ["user_id", "comment_id"], name: "index_comment_smiles_on_user_id_and_comment_id", unique: true
    t.index ["user_id"], name: "index_comment_smiles_on_user_id"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.string "content"
    t.integer "answer_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "smile_count", default: 0, null: false
    t.index ["user_id", "created_at"], name: "index_comments_on_user_id_and_created_at"
  end

  create_table "group_members", id: :serial, force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["group_id", "user_id"], name: "index_group_members_on_group_id_and_user_id", unique: true
    t.index ["group_id"], name: "index_group_members_on_group_id"
    t.index ["user_id"], name: "index_group_members_on_user_id"
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name"
    t.string "display_name"
    t.boolean "private", default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_groups_on_name"
    t.index ["user_id", "name"], name: "index_groups_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_groups_on_user_id"
  end

  create_table "inboxes", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "question_id"
    t.boolean "new"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "moderation_comments", id: :serial, force: :cascade do |t|
    t.integer "report_id"
    t.integer "user_id"
    t.string "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id", "created_at"], name: "index_moderation_comments_on_user_id_and_created_at"
  end

  create_table "moderation_votes", id: :serial, force: :cascade do |t|
    t.integer "report_id", null: false
    t.integer "user_id", null: false
    t.boolean "upvote", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["report_id"], name: "index_moderation_votes_on_report_id"
    t.index ["user_id", "report_id"], name: "index_moderation_votes_on_user_id_and_report_id", unique: true
    t.index ["user_id"], name: "index_moderation_votes_on_user_id"
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.string "target_type"
    t.integer "target_id"
    t.integer "recipient_id"
    t.boolean "new"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "questions", id: :serial, force: :cascade do |t|
    t.string "content"
    t.boolean "author_is_anonymous"
    t.string "author_name"
    t.string "author_email"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "answer_count", default: 0, null: false
    t.index ["user_id", "created_at"], name: "index_questions_on_user_id_and_created_at"
  end

  create_table "relationships", id: :serial, force: :cascade do |t|
    t.integer "source_id"
    t.integer "target_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["source_id", "target_id"], name: "index_relationships_on_source_id_and_target_id", unique: true
    t.index ["source_id"], name: "index_relationships_on_source_id"
    t.index ["target_id"], name: "index_relationships_on_target_id"
  end

  create_table "reports", id: :serial, force: :cascade do |t|
    t.string "type", null: false
    t.integer "target_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "deleted", default: false
    t.string "reason"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "services", id: :serial, force: :cascade do |t|
    t.string "type", null: false
    t.integer "user_id", null: false
    t.string "uid"
    t.string "access_token"
    t.string "access_secret"
    t.string "nickname"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "smiles", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "answer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["answer_id"], name: "index_smiles_on_answer_id"
    t.index ["user_id", "answer_id"], name: "index_smiles_on_user_id_and_answer_id", unique: true
    t.index ["user_id"], name: "index_smiles_on_user_id"
  end

  create_table "subscriptions", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "answer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_active", default: true
  end

  create_table "themes", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "primary_color", default: 6174129
    t.integer "primary_text", default: 16777215
    t.integer "danger_color", default: 16711737
    t.integer "danger_text", default: 16777215
    t.integer "success_color", default: 4175384
    t.integer "success_text", default: 16777215
    t.integer "warning_color", default: 16741656
    t.integer "warning_text", default: 16777215
    t.integer "info_color", default: 10048699
    t.integer "info_text", default: 16777215
    t.integer "default_color", default: 2236962
    t.integer "default_text", default: 15658734
    t.integer "panel_color", default: 16382457
    t.integer "panel_text", default: 1381653
    t.integer "link_color", default: 6174129
    t.integer "background_color", default: 16777215
    t.integer "background_text", default: 2236962
    t.integer "background_muted", default: 12303291
    t.string "css_file_name"
    t.string "css_content_type"
    t.integer "css_file_size"
    t.datetime "css_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "input_color", default: 16777215, null: false
    t.integer "input_text", default: 0, null: false
    t.integer "outline_color", default: 6174129, null: false
    t.index ["user_id", "created_at"], name: "index_themes_on_user_id_and_created_at"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "screen_name"
    t.integer "friend_count", default: 0, null: false
    t.integer "follower_count", default: 0, null: false
    t.integer "asked_count", default: 0, null: false
    t.integer "answered_count", default: 0, null: false
    t.integer "commented_count", default: 0, null: false
    t.string "display_name"
    t.integer "smiled_count", default: 0, null: false
    t.boolean "admin", default: false, null: false
    t.string "motivation_header", default: "", null: false
    t.string "website", default: "", null: false
    t.string "location", default: "", null: false
    t.text "bio", default: "", null: false
    t.boolean "moderator", default: false, null: false
    t.string "profile_picture_file_name"
    t.string "profile_picture_content_type"
    t.integer "profile_picture_file_size"
    t.datetime "profile_picture_updated_at"
    t.boolean "profile_picture_processing"
    t.integer "crop_x"
    t.integer "crop_y"
    t.integer "crop_w"
    t.integer "crop_h"
    t.boolean "supporter", default: false
    t.boolean "privacy_allow_anonymous_questions", default: true
    t.boolean "privacy_allow_public_timeline", default: true
    t.boolean "privacy_allow_stranger_answers", default: true
    t.boolean "privacy_show_in_search", default: true
    t.boolean "permanently_banned", default: false
    t.boolean "blogger", default: false
    t.boolean "contributor", default: false
    t.string "ban_reason"
    t.datetime "banned_until"
    t.integer "comment_smiled_count", default: 0, null: false
    t.string "profile_header_file_name"
    t.string "profile_header_content_type"
    t.integer "profile_header_file_size"
    t.datetime "profile_header_updated_at"
    t.boolean "profile_header_processing"
    t.integer "crop_h_x"
    t.integer "crop_h_y"
    t.integer "crop_h_w"
    t.integer "crop_h_h"
    t.string "locale", default: "en"
    t.boolean "translator", default: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.boolean "show_foreign_themes", default: true, null: false
    t.string "export_url"
    t.boolean "export_processing", default: false, null: false
    t.datetime "export_created_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["screen_name"], name: "index_users_on_screen_name", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
end
