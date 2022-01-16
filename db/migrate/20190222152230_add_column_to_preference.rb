class AddColumnToPreference < ActiveRecord::Migration[5.2]
  def change
    add_column :preferences, :headline_interval, :integer, null: false, default: 10_000, after: :default_color_edge
  end
end
