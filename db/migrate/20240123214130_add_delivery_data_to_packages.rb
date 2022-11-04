class AddDeliveryDataToPackages < ActiveRecord::Migration[7.0]
  def change
    add_reference :packages, :admin_user, foreign_key: true
    add_column :packages, :delivered_at, :datetime
  end
end
