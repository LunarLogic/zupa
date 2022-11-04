class AddDeliveredByToPackages < ActiveRecord::Migration[7.0]
  def change
    add_column :packages, :delivered_by, :string
  end
end
