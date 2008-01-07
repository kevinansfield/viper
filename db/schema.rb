# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 31) do

  create_table "articles", :force => true do |t|
    t.integer  "user_id"
    t.integer  "category_id"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  create_table "avatars", :force => true do |t|
    t.integer "user_id"
    t.integer "parent_id"
    t.string  "content_type"
    t.string  "filename"
    t.string  "thumbnail"
    t.integer "size"
    t.integer "width"
    t.integer "height"
    t.string  "crop_options"
    t.string  "version_name"
    t.integer "base_version_id"
    t.integer "file_size"
    t.float   "aspect_ratio"
  end

  create_table "bios", :force => true do |t|
    t.integer "user_id"
    t.text    "about"
    t.text    "interests"
    t.text    "music"
    t.text    "films"
    t.text    "television"
    t.text    "books"
    t.text    "heroes"
    t.text    "author_about"
  end

  create_table "blogs", :force => true do |t|
    t.integer "user_id"
  end

  create_table "categories", :force => true do |t|
    t.string "name"
    t.text   "description"
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "post_id"
    t.text     "body"
    t.datetime "created_at"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.string   "user_ip"
    t.string   "user_agent"
    t.string   "referrer"
    t.boolean  "approved",         :default => false, :null => false
  end

  create_table "emails", :force => true do |t|
    t.string   "from"
    t.string   "to"
    t.integer  "last_send_attempt", :default => 0
    t.text     "mail"
    t.datetime "created_on"
  end

  create_table "friendships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "accepted_at"
  end

  create_table "im_contacts", :force => true do |t|
    t.integer "profile_id"
    t.string  "contact"
    t.string  "service"
  end

  create_table "messages", :force => true do |t|
    t.integer  "sender_id",                        :null => false
    t.integer  "receiver_id",                      :null => false
    t.string   "subject",          :default => "", :null => false
    t.text     "body"
    t.datetime "created_at"
    t.datetime "read_at"
    t.boolean  "sender_deleted"
    t.boolean  "receiver_deleted"
    t.boolean  "sender_purged"
    t.boolean  "receiver_purged"
  end

  add_index "messages", ["sender_id"], :name => "index_messages_on_sender_id"
  add_index "messages", ["receiver_id"], :name => "index_messages_on_receiver_id"

  create_table "news", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "posts", :force => true do |t|
    t.integer  "blog_id"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles", :force => true do |t|
    t.integer "user_id",    :default => 0,  :null => false
    t.string  "first_name"
    t.string  "last_name"
    t.string  "gender"
    t.date    "birthdate"
    t.string  "city"
    t.string  "county"
    t.string  "post_code"
    t.float   "lat"
    t.float   "lng"
    t.string  "occupation", :default => ""
    t.string  "website"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "new_email"
    t.string   "email_activation_code",     :limit => 40
    t.string   "password_reset_code",       :limit => 40
    t.boolean  "admin",                                   :default => false
    t.string   "permalink"
    t.integer  "hits",                                    :default => 0
  end

  create_table "walls", :force => true do |t|
    t.integer "user_id"
  end

end
