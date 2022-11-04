class AddRequestedByToItemRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :item_requests, :requested_by, :string
  end
end
