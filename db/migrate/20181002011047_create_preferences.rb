class CreatePreferences < ActiveRecord::Migration[5.2]
  def change
    create_table :preferences do |t|
      t.string :role_default_name
      t.string :role_default_person
      t.boolean :preview_locale_jp, null: false
      t.boolean :under_construction, null: false
      t.integer :projects_display_count, null: false
      t.string :default_color_edge, null: false

      t.timestamps
    end
  end
end
