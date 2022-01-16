class CreateLogins < ActiveRecord::Migration[5.2]
  def change
    create_table :logins do |t|
      t.integer :admin_id
      t.string :name
      t.string :password
      t.string :ip
      t.string :language
      t.string :user_agent

      t.timestamps
    end
  end
end
