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

ActiveRecord::Schema.define(version: 20150708052026) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "activities", force: :cascade do |t|
    t.integer  "owner_id",                null: false
    t.integer  "community_id",            null: false
    t.integer  "resource_id",             null: false
    t.string   "resource_type",           null: false
    t.integer  "secondary_resource_id"
    t.string   "secondary_resource_type"
    t.json     "data"
    t.string   "type",                    null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "activities", ["community_id"], name: "index_activities_on_community_id", using: :btree
  add_index "activities", ["id", "type"], name: "index_activities_on_id_and_type", using: :btree
  add_index "activities", ["owner_id"], name: "index_activities_on_owner_id", using: :btree
  add_index "activities", ["resource_id", "resource_type"], name: "index_activities_on_resource_id_and_resource_type", using: :btree
  add_index "activities", ["secondary_resource_id", "secondary_resource_type"], name: "activities_secondary_resource_index", using: :btree

  create_table "availabilities", force: :cascade do |t|
    t.integer  "member_id",                       null: false
    t.boolean  "recurring",       default: false, null: false
    t.time     "time",                            null: false
    t.date     "date",                            null: false
    t.string   "time_zone"
    t.string   "location_type"
    t.string   "location_detail"
    t.integer  "wday"
    t.integer  "duration"
    t.integer  "slot_duration"
    t.text     "details"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "community_id"
  end

  add_index "availabilities", ["community_id"], name: "index_availabilities_on_community_id", using: :btree
  add_index "availabilities", ["member_id"], name: "index_availabilities_on_member_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer  "author_id"
    t.integer  "discussion_id"
    t.text     "body"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "comments", ["author_id"], name: "index_comments_on_author_id", using: :btree
  add_index "comments", ["discussion_id"], name: "index_comments_on_discussion_id", using: :btree

  create_table "communities", force: :cascade do |t|
    t.string   "name",                               null: false
    t.string   "slug",                               null: false
    t.string   "logo"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "email"
    t.text     "social_media_services", default: [],              array: true
  end

  create_table "companies", force: :cascade do |t|
    t.string   "name",         null: false
    t.string   "website"
    t.text     "description"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "logo"
    t.integer  "community_id"
  end

  add_index "companies", ["community_id"], name: "index_companies_on_community_id", using: :btree

  create_table "discussions", force: :cascade do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "community_id"
    t.integer  "author_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "comments_count"
    t.integer  "follows_count"
  end

  add_index "discussions", ["author_id"], name: "index_discussions_on_author_id", using: :btree
  add_index "discussions", ["community_id"], name: "index_discussions_on_community_id", using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "location_detail",                                                  null: false
    t.string   "location_type",                                                    null: false
    t.datetime "starts_at",                                                        null: false
    t.datetime "ends_at",                                                          null: false
    t.string   "title",                                                            null: false
    t.string   "time_zone",                                                        null: false
    t.text     "description"
    t.integer  "creator_id",                                                       null: false
    t.integer  "community_id"
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
    t.boolean  "external",                                    default: false,      null: false
    t.decimal  "location_latitude",  precision: 10, scale: 6, default: 2.909047,   null: false
    t.decimal  "location_longitude", precision: 10, scale: 6, default: 101.654669, null: false
    t.integer  "location_zoom",                               default: 15,         null: false
  end

  add_index "events", ["community_id"], name: "index_events_on_community_id", using: :btree
  add_index "events", ["creator_id"], name: "index_events_on_creator_id", using: :btree

  create_table "follows", force: :cascade do |t|
    t.integer  "followable_id"
    t.string   "followable_type"
    t.integer  "member_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "follows", ["followable_id", "followable_type"], name: "index_follows_on_followable_id_and_followable_type", using: :btree
  add_index "follows", ["member_id"], name: "index_follows_on_member_id", using: :btree

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "members", force: :cascade do |t|
    t.string   "first_name",             default: "", null: false
    t.string   "last_name",              default: "", null: false
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
    t.string   "avatar"
    t.string   "time_zone"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",      default: 0
    t.integer  "community_id"
    t.integer  "follows_count"
    t.hstore   "notifications",          default: {}, null: false
    t.text     "description"
    t.integer  "discussions_count"
    t.integer  "availabilities_count"
    t.integer  "magic_connect_id"
  end

  add_index "members", ["community_id", "email"], name: "index_members_on_community_id_and_email", unique: true, using: :btree
  add_index "members", ["community_id"], name: "index_members_on_community_id", using: :btree
  add_index "members", ["confirmation_token"], name: "index_members_on_confirmation_token", unique: true, using: :btree
  add_index "members", ["invitation_token"], name: "index_members_on_invitation_token", unique: true, using: :btree
  add_index "members", ["invitations_count"], name: "index_members_on_invitations_count", using: :btree
  add_index "members", ["invited_by_id"], name: "index_members_on_invited_by_id", using: :btree
  add_index "members", ["reset_password_token"], name: "index_members_on_reset_password_token", unique: true, using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "sender_id",                  null: false
    t.integer  "receiver_id",                null: false
    t.text     "body",                       null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "unread",      default: true
  end

  add_index "messages", ["receiver_id"], name: "index_messages_on_receiver_id", using: :btree
  add_index "messages", ["sender_id"], name: "index_messages_on_sender_id", using: :btree

  create_table "networks", force: :cascade do |t|
    t.string   "name"
    t.integer  "community_id"
    t.string   "slug"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "networks", ["community_id"], name: "index_networks_on_community_id", using: :btree
  add_index "networks", ["slug"], name: "index_networks_on_slug", unique: true, using: :btree

  create_table "positions", force: :cascade do |t|
    t.integer  "member_id",                    null: false
    t.integer  "community_id",                 null: false
    t.integer  "company_id",                   null: false
    t.boolean  "founder",      default: false, null: false
    t.string   "role"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "positions", ["community_id"], name: "index_positions_on_community_id", using: :btree
  add_index "positions", ["company_id", "member_id", "role", "founder"], name: "unique_position_index", unique: true, using: :btree
  add_index "positions", ["company_id"], name: "index_positions_on_company_id", using: :btree
  add_index "positions", ["member_id"], name: "index_positions_on_member_id", using: :btree

  create_table "rsvps", force: :cascade do |t|
    t.integer  "event_id"
    t.integer  "member_id"
    t.string   "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "rsvps", ["event_id"], name: "index_rsvps_on_event_id", using: :btree
  add_index "rsvps", ["member_id"], name: "index_rsvps_on_member_id", using: :btree

  create_table "slots", force: :cascade do |t|
    t.integer  "member_id",       null: false
    t.integer  "availability_id", null: false
    t.time     "start_time",      null: false
    t.time     "end_time",        null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "slots", ["availability_id"], name: "index_slots_on_availability_id", using: :btree
  add_index "slots", ["member_id"], name: "index_slots_on_member_id", using: :btree

  create_table "social_media_links", force: :cascade do |t|
    t.string  "service"
    t.string  "url"
    t.integer "attachable_id"
    t.string  "attachable_type"
    t.integer "community_id"
  end

  add_index "social_media_links", ["attachable_id", "attachable_type"], name: "index_social_media_links_on_attachable_id_and_attachable_type", using: :btree
  add_index "social_media_links", ["community_id"], name: "index_social_media_links_on_community_id", using: :btree
  add_index "social_media_links", ["service", "url", "attachable_id", "attachable_type", "community_id"], name: "index_social_media_links_on_unique_keys", unique: true, using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type"], name: "index_taggings_on_taggable_id_and_taggable_type", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name"
    t.string   "type"
    t.integer  "community_id"
    t.integer  "taggings_count"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "tags", ["community_id"], name: "index_tags_on_community_id", using: :btree
  add_index "tags", ["id", "type"], name: "index_tags_on_id_and_type", using: :btree

  add_foreign_key "comments", "discussions"
  add_foreign_key "companies", "communities"
  add_foreign_key "discussions", "communities"
  add_foreign_key "follows", "members"
  add_foreign_key "members", "communities"
  add_foreign_key "networks", "communities"
  add_foreign_key "rsvps", "events"
  add_foreign_key "rsvps", "members"
  add_foreign_key "taggings", "tags"
  add_foreign_key "tags", "communities"
end
