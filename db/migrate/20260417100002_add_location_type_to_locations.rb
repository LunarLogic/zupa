class AddLocationTypeToLocations < ActiveRecord::Migration[7.0]
  def change
    create_enum :location_type, ["regular", "estimated"]

    add_column :locations, :location_type, :enum, enum_type: :location_type, default: "regular", null: false
    add_column :locations, :estimated_person_count, :integer, default: 0, null: false
  end
end
