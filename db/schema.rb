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

ActiveRecord::Schema.define(:version => 9) do

  create_table "comments", :force => true do |t|
    t.integer  "note_id"
    t.string   "author_name"
    t.string   "author_email"
    t.string   "author_url"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "notes", :force => true do |t|
    t.integer  "user_id"
    t.text     "text"
    t.integer  "blog_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_type"
    t.string   "title"
    t.string   "notify_id_list"
    t.string   "summary"
  end

  add_index "notes", ["user_id", "user_type", "created_at"], :name => "index_notes_on_user_id_and_user_type_and_created_at"
  add_index "notes", ["user_id", "user_type"], :name => "index_notes_on_user_id_and_user_type"
  add_index "notes", ["blog_id"], :name => "index_notes_on_blog_id"
  add_index "notes", ["user_id"], :name => "index_notes_on_user_id"

end
