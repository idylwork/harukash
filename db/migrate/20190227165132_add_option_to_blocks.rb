class AddOptionToBlocks < ActiveRecord::Migration[5.2]
  def change
    add_column :blocks, :option, :string, after: :is_portrait
    add_column :published_blocks, :option, :string, after: :is_portrait
  end
end
