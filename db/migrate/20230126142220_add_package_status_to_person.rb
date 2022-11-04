class AddPackageStatusToPerson < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :package_status, :integer, null: false, default: 0
  end
end
