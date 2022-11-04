class RemoveNullConstraintOnCode < ActiveRecord::Migration[7.0]
  def change
    change_column_null :people, :code, true
  end
end
