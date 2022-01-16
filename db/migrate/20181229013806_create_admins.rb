class CreateAdmins < ActiveRecord::Migration[5.2]
  def change
    create_table :admins do |t|
      t.string :name, null: false
      t.string :level, null: false
      t.string :email, null: false
      t.boolean :sendmail, null: false, default: false
      t.string :password_digest, null: false
      t.string :remember_token
      t.timestamps
    end
  end
end
