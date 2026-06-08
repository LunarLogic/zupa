class CreateTripGroupsDrivers < ActiveRecord::Migration[7.0]
  def change
    create_table :trip_groups_drivers, id: false do |t|
      t.belongs_to :trip_group, null: false
      t.belongs_to :volunteer, null: false
      t.index [:trip_group_id, :volunteer_id], unique: true, name: "index_tgd_on_trip_group_and_volunteer"
    end
    add_foreign_key :trip_groups_drivers, :trip_groups, on_delete: :cascade
    add_foreign_key :trip_groups_drivers, :volunteers, on_delete: :restrict
  end
end
