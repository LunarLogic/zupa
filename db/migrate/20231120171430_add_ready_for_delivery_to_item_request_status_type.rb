class AddReadyForDeliveryToItemRequestStatusType < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    execute <<-SQL
      ALTER TYPE item_request_status_type ADD VALUE 'packing';
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
