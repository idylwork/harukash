class RemoveDateFromPages < ActiveRecord::Migration[5.2]
  def change
    remove_column :pages, :date, :date
  end
end
