class CreateRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :roles do |t|
      t.integer :project_id, null: false
      t.integer :display_id, null: false
      t.text :name, null: false
      t.text :person, null: false

      t.timestamps
    end
  end
end
