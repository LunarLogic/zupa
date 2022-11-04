class CreatePackageStatusTypeEnum < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      CREATE TYPE package_status_type AS ENUM ('packing', 'packed', 'delivered');
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE package_status_type;
    SQL
  end
end
