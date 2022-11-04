class AddGroupNumberToTripGroup < ActiveRecord::Migration[7.0]
  def change
    add_column :trip_groups, :number, :integer
  end
end
