class ChangeColumnToBlocks < ActiveRecord::Migration[5.2]
  def change
    change_column :blocks, :display_id, :integer, null: false
    change_column :published_blocks, :display_id, :integer, null: false
  end
end
