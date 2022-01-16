class AddProfilesToPreferences < ActiveRecord::Migration[5.2]
  def change
    add_column :preferences, :profile_en, :text, after: :id
    add_column :preferences, :profile_jp, :text, after: :profile_en
  end
end
