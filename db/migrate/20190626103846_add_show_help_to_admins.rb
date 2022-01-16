class AddShowHelpToAdmins < ActiveRecord::Migration[5.2]
  def change
    add_column :admins, :show_help, :boolean, null: false, default: false, after: :remember_token
  end
end
