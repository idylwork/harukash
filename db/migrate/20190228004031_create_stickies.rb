class CreateStickies < ActiveRecord::Migration[5.2]
  def change
    create_table :stickies do |t|
      t.text :html_en
      t.text :html_jp
      t.string :color_txt
      t.string :color_bg_start
      t.string :color_bg_end
      t.string :file
      t.datetime :start_at
      t.datetime :end_at
      t.boolean :is_visible, null: false, default: false

      t.timestamps
    end
  end
end
