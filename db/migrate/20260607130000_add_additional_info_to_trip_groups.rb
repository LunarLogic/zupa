class AddAdditionalInfoToTripGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :trip_groups, :additional_info, :text
  end
end
