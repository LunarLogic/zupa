class RenameNameToFirstName < ActiveRecord::Migration[7.0]
  def change
    rename_column :people, :name, :first_name
  end
end
