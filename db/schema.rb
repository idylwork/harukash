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

ActiveRecord::Schema.define(version: 2019_06_26_103846) do
  create_table "admins", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "level", null: false
    t.string "email", null: false
    t.boolean "sendmail", default: false, null: false
    t.string "password_digest", null: false
    t.string "remember_token"
    t.boolean "show_help", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "blocks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "display_id", null: false
    t.string "type", null: false
    t.text "text_en"
    t.text "text_jp"
    t.string "color_txt"
    t.string "color_bg"
    t.string "file"
    t.boolean "is_portrait", default: false, null: false
    t.string "option"
    t.boolean "is_visible", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.integer "display_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contacts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "headlines", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "display_id", null: false
    t.string "source", null: false
    t.integer "published_project_id"
    t.integer "published_block_id"
    t.string "file"
    t.integer "position_x", default: 50, null: false
    t.integer "position_y", default: 50, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "logins", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "admin_id"
    t.string "name"
    t.string "password"
    t.string "ip"
    t.string "language"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "source", null: false
    t.integer "category_id"
    t.integer "published_project_id"
    t.integer "order"
  end

  create_table "preferences", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "profile_en"
    t.text "profile_jp"
    t.string "role_default_name"
    t.string "role_default_person"
    t.boolean "preview_locale_jp", null: false
    t.boolean "under_construction", null: false
    t.integer "projects_display_count", null: false
    t.string "default_color_edge", null: false
    t.integer "headline_interval", default: 10000, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "projects", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title", null: false
    t.integer "category_id", null: false
    t.date "date"
    t.string "color_txt"
    t.string "color_bg"
    t.string "color_edge"
    t.string "file"
    t.boolean "is_portrait", default: false, null: false
    t.boolean "is_visible", default: false, null: false
    t.text "overview_en"
    t.text "overview_jp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "published_blocks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "published_project_id", null: false
    t.integer "display_id", null: false
    t.string "type", null: false
    t.text "text_en"
    t.text "text_jp"
    t.string "color_txt"
    t.string "color_bg"
    t.string "file"
    t.boolean "is_portrait", default: false, null: false
    t.string "option"
    t.boolean "is_visible", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "published_projects", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title", null: false
    t.integer "category_id", null: false
    t.date "date"
    t.string "color_txt"
    t.string "color_bg"
    t.string "color_edge"
    t.string "file"
    t.boolean "is_portrait", default: false, null: false
    t.boolean "is_visible", default: false, null: false
    t.text "overview_en"
    t.text "overview_jp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "published_roles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "published_project_id", null: false
    t.integer "display_id", null: false
    t.text "name", null: false
    t.text "person", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "display_id", null: false
    t.text "name", null: false
    t.text "person", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stickies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "html_en"
    t.text "html_jp"
    t.string "color_txt"
    t.string "color_bg_start"
    t.string "color_bg_end"
    t.string "file"
    t.datetime "start_at"
    t.datetime "end_at"
    t.boolean "is_visible", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
