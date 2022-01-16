class CreateHeadlines < ActiveRecord::Migration[5.2]
  def change
    create_table :headlines do |t|
      t.integer :display_id, null: false
      t.string :source, null: false
      t.integer :published_project_id
      t.integer :published_block_id
      t.string :file
      t.integer :position_x, null: false, default: 50
      t.integer :position_y, null: false, default: 50

      t.timestamps
    end
  end
end
