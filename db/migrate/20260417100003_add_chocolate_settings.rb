class AddChocolateSettings < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :extra_chocolates, :integer, default: 0, null: false
    add_column :app_settings, :chocolates_per_person, :integer, default: 1, null: false
    add_column :app_settings, :sandwiches_per_person, :integer, default: 2, null: false
  end
end
