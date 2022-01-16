class CreateProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :projects do |t|
      t.string :title, null: false
      t.integer :category_id, null: false
      t.date :date
      t.string :color_txt
      t.string :color_bg
      t.string :color_edge
      t.string :file
      t.boolean :is_portrait, null: false, default: false
      t.boolean :is_visible, null: false, default: false
      t.text :overview_en
      t.text :overview_jp

      t.timestamps
    end
  end
end
