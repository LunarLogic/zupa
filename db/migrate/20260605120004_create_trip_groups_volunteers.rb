class CreateTripGroupsVolunteers < ActiveRecord::Migration[7.0]
  def change
    create_join_table :trip_groups, :volunteers do |t|
      t.index [:trip_group_id, :volunteer_id], unique: true, name: "index_tgv_on_trip_group_and_volunteer"
      t.index :volunteer_id
    end
    add_foreign_key :trip_groups_volunteers, :trip_groups, on_delete: :cascade
    add_foreign_key :trip_groups_volunteers, :volunteers, on_delete: :restrict
  end
end
