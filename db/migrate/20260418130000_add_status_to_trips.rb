class AddStatusToTrips < ActiveRecord::Migration[7.0]
  def change
    add_column :trips, :status, :integer, default: 0, null: false
    add_index :trips, :status
  end
end
