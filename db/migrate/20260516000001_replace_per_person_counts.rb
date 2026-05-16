class ReplacePerPersonCounts < ActiveRecord::Migration[7.0]
  def up
    default_chocolates = 1
    default_sandwiches = 2
    if connection.table_exists?(:app_settings)
      row = connection.select_one("SELECT chocolates_per_person, sandwiches_per_person FROM app_settings LIMIT 1")
      if row
        default_chocolates = row["chocolates_per_person"]
        default_sandwiches = row["sandwiches_per_person"]
      end
    end

    add_column :app_settings, :soups_per_person, :integer, default: 1, null: false unless column_exists?(:app_settings, :soups_per_person)
    add_column :app_settings, :sparkling_water_per_person, :integer, default: 0, null: false unless column_exists?(:app_settings, :sparkling_water_per_person)
    add_column :app_settings, :still_water_per_person, :integer, default: 0, null: false unless column_exists?(:app_settings, :still_water_per_person)

    add_column :people, :soups, :integer, default: 0, null: false unless column_exists?(:people, :soups)
    add_column :people, :chocolates, :integer, default: 0, null: false unless column_exists?(:people, :chocolates)
    add_column :people, :sandwiches, :integer, default: 0, null: false unless column_exists?(:people, :sandwiches)

    rename_column :people, :sparkling_water_count, :sparkling_water if column_exists?(:people, :sparkling_water_count)
    rename_column :people, :still_water_count, :still_water if column_exists?(:people, :still_water_count)

    if column_exists?(:people, :extra_chocolates)
      execute <<~SQL
        UPDATE people SET
          soups = 1,
          chocolates = #{default_chocolates} + COALESCE(extra_chocolates, 0),
          sandwiches = #{default_sandwiches}
      SQL

      remove_column :people, :extra_chocolates
    end
  end

  def down
    add_column :people, :extra_chocolates, :integer, default: 0, null: false
    rename_column :people, :sparkling_water, :sparkling_water_count
    rename_column :people, :still_water, :still_water_count
    remove_column :people, :sandwiches
    remove_column :people, :chocolates
    remove_column :people, :soups

    remove_column :app_settings, :still_water_per_person
    remove_column :app_settings, :sparkling_water_per_person
    remove_column :app_settings, :soups_per_person
  end
end
