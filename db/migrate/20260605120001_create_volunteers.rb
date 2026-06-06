class CreateVolunteers < ActiveRecord::Migration[7.0]
  def change
    create_table :volunteers do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :volunteers, [:first_name, :last_name], unique: true
  end
end
