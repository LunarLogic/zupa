class AddSoupsPerPersonToAppSettings < ActiveRecord::Migration[7.0]
  def change
    add_column :app_settings, :soups_per_person, :integer, default: 1, null: false
  end
end
