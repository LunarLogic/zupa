class AddPackageRefToItemRequests < ActiveRecord::Migration[7.0]
  def change
    add_reference :item_requests, :package, foreign_key: true
  end
end
