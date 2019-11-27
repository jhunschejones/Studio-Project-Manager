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

ActiveRecord::Schema.define(version: 2019_11_27_211140) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: :cascade do |t|
    t.string "title", null: false
    t.text "body", null: false
    t.bigint "project_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["project_id"], name: "index_comments_on_project_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "download_links", force: :cascade do |t|
    t.string "title", null: false
    t.string "link", null: false
    t.bigint "track_id"
    t.bigint "project_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["project_id"], name: "index_download_links_on_project_id"
    t.index ["track_id"], name: "index_download_links_on_track_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.datetime "scheduled_for", null: false
    t.datetime "completed_on"
    t.bigint "project_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["project_id"], name: "index_events_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.string "upload_link"
    t.boolean "is_archived", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["title"], name: "index_projects_on_title", where: "(is_archived = false)"
  end

  create_table "projects_users", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "project_id", null: false
    t.index ["project_id"], name: "index_projects_users_on_project_id"
    t.index ["user_id"], name: "index_projects_users_on_user_id"
  end

  create_table "revision_notes", force: :cascade do |t|
    t.text "body"
    t.boolean "is_user_editable"
    t.boolean "is_completed"
    t.string "track_version"
    t.bigint "track_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["track_id"], name: "index_revision_notes_on_track_id"
    t.index ["user_id"], name: "index_revision_notes_on_user_id"
  end

  create_table "tracks", force: :cascade do |t|
    t.string "title", null: false
    t.boolean "is_completed", default: false
    t.bigint "project_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["project_id"], name: "index_tracks_on_project_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "role", default: "user"
    t.string "password_digest", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "email_verification_token"
    t.datetime "email_verification_sent_at"
    t.string "unconfirmed_email"
    t.boolean "is_verified", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "comments", "projects"
  add_foreign_key "comments", "users"
  add_foreign_key "download_links", "projects"
  add_foreign_key "download_links", "tracks"
  add_foreign_key "events", "projects"
  add_foreign_key "revision_notes", "tracks"
  add_foreign_key "revision_notes", "users"
  add_foreign_key "tracks", "projects"
end
