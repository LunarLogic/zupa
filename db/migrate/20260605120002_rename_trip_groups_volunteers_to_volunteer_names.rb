class RenameTripGroupsVolunteersToVolunteerNames < ActiveRecord::Migration[7.0]
  def change
    rename_column :trip_groups, :volunteers, :volunteer_names
  end
end
