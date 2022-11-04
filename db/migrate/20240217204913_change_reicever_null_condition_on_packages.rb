class ChangeReiceverNullConditionOnPackages < ActiveRecord::Migration[7.0]
  def change
    change_column_null :packages, :receiver_id, false
  end
end
