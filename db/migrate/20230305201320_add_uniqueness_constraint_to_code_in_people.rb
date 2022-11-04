class AddUniquenessConstraintToCodeInPeople < ActiveRecord::Migration[7.0]
  def change
    add_index :people, :code, unique: true
  end
end
