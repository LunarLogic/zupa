class RemoveAdminUserFromPackages < ActiveRecord::Migration[7.0]
  def change
    remove_reference :packages, :admin_user, null: false, foreign_key: true
  end
end
