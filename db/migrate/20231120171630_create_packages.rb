class CreatePackages < ActiveRecord::Migration[7.0]
  def change
    create_table :packages do |t|
      t.references :receiver, null: true, foreign_key: {to_table: :people}
      t.enum :status, null: false, enum_type: "package_status_type", default: "packing"
      t.timestamps
    end
  end
end
