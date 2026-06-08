class AddGenderToVolunteers < ActiveRecord::Migration[7.0]
  def change
    add_column :volunteers, :gender, :string
  end
end
