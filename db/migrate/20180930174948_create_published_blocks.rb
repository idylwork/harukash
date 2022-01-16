class CreatePublishedBlocks < ActiveRecord::Migration[5.2]
  def change
    create_table :published_blocks do |t|
      t.integer :published_project_id, null: false
      t.string :display_id, null: false
      t.string :type, null: false
      t.text :text_en
      t.text :text_jp
      t.string :color_txt
      t.string :color_bg
      t.string :file
      t.boolean :is_portrait, null: false, default: false
      t.boolean :is_visible, null: false, default: true

      t.timestamps
    end
  end
end
