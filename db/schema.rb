# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_03_01_203930) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "announcements", force: :cascade do |t|
    t.text "content", null: false
    t.string "link_text"
    t.string "link_href"
    t.datetime "starts_at", precision: nil, null: false
    t.datetime "ends_at", precision: nil, null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["starts_at", "ends_at"], name: "index_announcements_on_starts_at_and_ends_at", order: :desc
    t.index ["user_id"], name: "index_announcements_on_user_id"
  end

  create_table "anonymous_blocks", force: :cascade do |t|
    t.bigint "user_id"
    t.string "identifier"
    t.bigint "question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "target_user_id"
    t.index ["identifier"], name: "index_anonymous_blocks_on_identifier"
    t.index ["question_id"], name: "index_anonymous_blocks_on_question_id"
    t.index ["target_user_id"], name: "index_anonymous_blocks_on_target_user_id"
    t.index ["user_id"], name: "index_anonymous_blocks_on_user_id"
  end

  create_table "answers", id: :bigint, default: -> { "gen_timestamp_id('answers'::text)" }, force: :cascade do |t|
    t.text "content"
    t.bigint "question_id"
    t.integer "comment_count", default: 0, null: false
    t.bigint "user_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "smile_count", default: 0, null: false
    t.datetime "pinned_at", precision: nil
    t.index ["created_at"], name: "index_answers_on_created_at", order: :desc
    t.index ["question_id"], name: "index_answers_on_question_id"
    t.index ["user_id", "created_at"], name: "index_answers_on_user_id_and_created_at"
    t.index ["user_id", "pinned_at"], name: "index_answers_on_user_id_and_pinned_at"
  end

  create_table "comments", id: :bigint, default: -> { "gen_timestamp_id('comments'::text)" }, force: :cascade do |t|
    t.string "content"
    t.bigint "answer_id"
    t.bigint "user_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "smile_count", default: 0, null: false
    t.index ["answer_id"], name: "index_comments_on_answer_id"
    t.index ["user_id", "created_at"], name: "index_comments_on_user_id_and_created_at"
  end

  create_table "inbox_entries", id: :serial, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "question_id"
    t.boolean "new"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["question_id"], name: "index_inbox_entries_on_question_id"
    t.index ["user_id"], name: "index_inbox_entries_on_user_id"
  end

  create_table "list_members", id: :serial, force: :cascade do |t|
    t.integer "list_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["list_id", "user_id"], name: "index_list_members_on_list_id_and_user_id", unique: true
  end

  create_table "lists", id: :serial, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.string "display_name"
    t.boolean "private", default: true
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["user_id", "name"], name: "index_lists_on_user_id_and_name", unique: true
  end

  create_table "mute_rules", id: :bigint, default: -> { "gen_timestamp_id('mute_rules'::text)" }, force: :cascade do |t|
    t.bigint "user_id"
    t.string "muted_phrase"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id"], name: "index_mute_rules_on_user_id"
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.string "target_type"
    t.bigint "target_id"
    t.bigint "recipient_id"
    t.boolean "new"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "type", null: false
    t.index ["new"], name: "index_notifications_on_new"
    t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
    t.index ["type"], name: "index_notifications_on_type"
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "user_id"
    t.string "display_name"
    t.string "description", default: "", null: false
    t.string "location", default: "", null: false
    t.string "website", default: "", null: false
    t.string "motivation_header", default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "anon_display_name"
    t.boolean "allow_long_questions", default: false
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "questions", id: :bigint, default: -> { "gen_timestamp_id('questions'::text)" }, force: :cascade do |t|
    t.string "content"
    t.boolean "author_is_anonymous"
    t.string "author_identifier"
    t.bigint "user_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "answer_count", default: 0, null: false
    t.boolean "direct", default: false, null: false
    t.index ["user_id", "created_at"], name: "index_questions_on_user_id_and_created_at"
  end

  create_table "reactions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "parent_id", null: false
    t.string "parent_type", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id", "parent_type"], name: "index_reactions_on_parent_id_and_parent_type"
    t.index ["parent_type", "parent_id", "user_id"], name: "index_reactions_on_parent_type_and_parent_id_and_user_id", unique: true
    t.index ["user_id", "created_at"], name: "index_reactions_on_user_id_and_created_at"
  end

  create_table "relationships", id: :serial, force: :cascade do |t|
    t.bigint "source_id"
    t.bigint "target_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "type", null: false
    t.index ["source_id", "target_id", "type"], name: "index_relationships_on_source_id_and_target_id_and_type", unique: true
    t.index ["source_id"], name: "index_relationships_on_source_id"
    t.index ["target_id"], name: "index_relationships_on_target_id"
    t.index ["type"], name: "index_relationships_on_type"
  end

  create_table "reports", id: :serial, force: :cascade do |t|
    t.string "type", null: false
    t.bigint "target_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "deleted", default: false
    t.string "reason"
    t.bigint "target_user_id"
    t.index ["target_user_id"], name: "index_reports_on_target_user_id"
    t.index ["type", "target_id"], name: "index_reports_on_type_and_target_id"
    t.index ["user_id", "created_at"], name: "index_reports_on_user_id_and_created_at"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "rpush_apps", force: :cascade do |t|
    t.string "name", null: false
    t.string "environment"
    t.text "certificate"
    t.string "password"
    t.integer "connections", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type", null: false
    t.string "auth_key"
    t.string "client_id"
    t.string "client_secret"
    t.string "access_token"
    t.datetime "access_token_expiration", precision: nil
    t.text "apn_key"
    t.string "apn_key_id"
    t.string "team_id"
    t.string "bundle_id"
    t.boolean "feedback_enabled", default: true
  end

  create_table "rpush_feedback", force: :cascade do |t|
    t.string "device_token"
    t.datetime "failed_at", precision: nil, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "app_id"
    t.index ["device_token"], name: "index_rpush_feedback_on_device_token"
  end

  create_table "rpush_notifications", force: :cascade do |t|
    t.integer "badge"
    t.string "device_token"
    t.string "sound"
    t.text "alert"
    t.text "data"
    t.integer "expiry", default: 86400
    t.boolean "delivered", default: false, null: false
    t.datetime "delivered_at", precision: nil
    t.boolean "failed", default: false, null: false
    t.datetime "failed_at", precision: nil
    t.integer "error_code"
    t.text "error_description"
    t.datetime "deliver_after", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "alert_is_json", default: false, null: false
    t.string "type", null: false
    t.string "collapse_key"
    t.boolean "delay_while_idle", default: false, null: false
    t.text "registration_ids"
    t.integer "app_id", null: false
    t.integer "retries", default: 0
    t.string "uri"
    t.datetime "fail_after", precision: nil
    t.boolean "processing", default: false, null: false
    t.integer "priority"
    t.text "url_args"
    t.string "category"
    t.boolean "content_available", default: false, null: false
    t.text "notification"
    t.boolean "mutable_content", default: false, null: false
    t.string "external_device_id"
    t.string "thread_id"
    t.boolean "dry_run", default: false, null: false
    t.boolean "sound_is_json", default: false
    t.index ["delivered", "failed", "processing", "deliver_after", "created_at"], name: "index_rpush_notifications_multi", where: "((NOT delivered) AND (NOT failed))"
  end

  create_table "subscriptions", id: :serial, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "answer_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id", "answer_id"], name: "index_subscriptions_on_user_id_and_answer_id"
  end

  create_table "themes", id: :serial, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "primary_color", default: 6174129
    t.integer "primary_text", default: 16777215
    t.integer "danger_color", default: 14431557
    t.integer "danger_text", default: 16777215
    t.integer "success_color", default: 2664261
    t.integer "success_text", default: 16777215
    t.integer "warning_color", default: 16761095
    t.integer "warning_text", default: 2697513
    t.integer "info_color", default: 1548984
    t.integer "info_text", default: 16777215
    t.integer "dark_color", default: 3422784
    t.integer "dark_text", default: 15658734
    t.integer "raised_background", default: 16777215
    t.integer "background_color", default: 15789556
    t.integer "body_text", default: 0
    t.integer "muted_text", default: 7107965
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "input_color", default: 15789556, null: false
    t.integer "input_text", default: 0, null: false
    t.integer "raised_accent", default: 16250871
    t.integer "light_color", default: 16316922
    t.integer "light_text", default: 0
    t.integer "input_placeholder", default: 7107965, null: false
    t.integer "raised_text", default: 0, null: false
    t.integer "raised_accent_text", default: 0, null: false
    t.index ["user_id"], name: "index_themes_on_user_id"
  end

  create_table "totp_recovery_codes", force: :cascade do |t|
    t.bigint "user_id"
    t.string "code", limit: 8
    t.index ["user_id", "code"], name: "index_totp_recovery_codes_on_user_id_and_code"
  end

  create_table "user_bans", force: :cascade do |t|
    t.bigint "user_id"
    t.string "reason"
    t.datetime "expires_at", precision: nil
    t.bigint "banned_by_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["expires_at"], name: "index_user_bans_on_expires_at", order: :desc
    t.index ["user_id"], name: "index_user_bans_on_user_id"
  end

  create_table "users", id: :bigint, default: -> { "gen_timestamp_id('users'::text)" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "screen_name"
    t.integer "asked_count", default: 0, null: false
    t.integer "answered_count", default: 0, null: false
    t.integer "commented_count", default: 0, null: false
    t.integer "smiled_count", default: 0, null: false
    t.string "profile_picture_file_name"
    t.boolean "profile_picture_processing"
    t.integer "profile_picture_x"
    t.integer "profile_picture_y"
    t.integer "profile_picture_w"
    t.integer "profile_picture_h"
    t.boolean "privacy_allow_anonymous_questions", default: true
    t.boolean "privacy_allow_public_timeline", default: true
    t.boolean "privacy_allow_stranger_answers", default: true
    t.boolean "privacy_show_in_search", default: true
    t.integer "comment_smiled_count", default: 0, null: false
    t.string "profile_header_file_name"
    t.boolean "profile_header_processing"
    t.integer "profile_header_x"
    t.integer "profile_header_y"
    t.integer "profile_header_w"
    t.integer "profile_header_h"
    t.string "locale", default: "en"
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.boolean "show_foreign_themes", default: true, null: false
    t.string "export_url"
    t.boolean "export_processing", default: false, null: false
    t.datetime "export_created_at", precision: nil
    t.string "otp_secret_key"
    t.integer "otp_module", default: 0, null: false
    t.boolean "privacy_lock_inbox", default: false
    t.boolean "privacy_require_user", default: false
    t.boolean "privacy_hide_social_graph", default: false
    t.boolean "privacy_noindex", default: false
    t.boolean "sharing_enabled", default: false
    t.boolean "sharing_autoclose", default: false
    t.string "sharing_custom_url"
    t.datetime "notifications_updated_at", precision: nil
    t.datetime "inbox_updated_at", precision: nil
    t.datetime "last_reports_visit"
    t.index "lower((screen_name)::text)", name: "index_users_on_LOWER_screen_name", unique: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  create_table "web_push_subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.json "subscription"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "failures", default: 0
    t.index ["user_id"], name: "index_web_push_subscriptions_on_user_id"
  end

  add_foreign_key "profiles", "users"
end
