class ChangeColumnToContact < ActiveRecord::Migration[5.2]
  def change
    change_column :contacts, :body, :text, null: false
  end
end
