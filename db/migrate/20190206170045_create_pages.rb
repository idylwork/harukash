class CreatePages < ActiveRecord::Migration[5.2]
  def change
    create_table :pages do |t|
      t.integer :source, null: false
      t.integer :category_id
      t.integer :published_project_id
      t.integer :order
      t.date :date
    end
  end
end
