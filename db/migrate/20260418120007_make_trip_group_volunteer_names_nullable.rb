class MakeTripGroupVolunteerNamesNullable < ActiveRecord::Migration[7.0]
  def change
    change_column_null :trip_groups, :volunteer_names, true
  end
end
