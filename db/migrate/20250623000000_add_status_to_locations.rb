class AddStatusToLocations < ActiveRecord::Migration[7.0]
  def change
    create_enum :location_status_type, ["active", "pending_verification", "inactive"]

    add_column :locations, :status, :enum, enum_type: :location_status_type, default: "active", null: false
  end
end
