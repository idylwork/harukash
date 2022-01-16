# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Category.create(name: "Client Works", display_id: 0)
Category.create(name: "Concept Art", display_id: 1)

Project.create(title: "First Project", category_id: 1, is_visible: true)

Preference.create(
  role_default_name: "Works",
  role_default_person: "Shoji Haruka",
  preview_locale_jp: false,
  under_construction: true,
  default_color_edge: "#ccd3dd",
  projects_display_count: 3
)

Sticky.create(
  html_en: "",
  html_jp: "",
  color_txt: "#ffffff",
  color_bg_start: "#89b1ba",
  color_bg_end: "#4a903a",
  is_visible: true,
  start_at: nil,
  end_at: nil
)

admin = Admin.new(name: "root", level: "root", password: "root", email: "init@example.com")
admin.save!(validate: false)
