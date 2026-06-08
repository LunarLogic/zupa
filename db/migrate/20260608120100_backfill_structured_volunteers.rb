class BackfillStructuredVolunteers < ActiveRecord::Migration[7.0]
  # One-time backfill: older sheet trips carry free-text `volunteer_names` but no
  # structured Volunteer links. New imports populate them at create time
  # (TripRepository#create_groups), and the wizard reads the structured links, so
  # this fills the gap for pre-existing trips. Idempotent: skips groups already
  # linked. Per-group rescue so one bad name can't abort the whole backfill.
  def up
    TripGroup.find_each do |group|
      next if group.volunteers.any? || group.drivers.any?
      next if group.volunteer_names.blank?

      begin
        Trips::SyncGroupVolunteers.new.call(group: group, names: group.volunteer_names)
      rescue => e
        say "Skipped trip_group ##{group.id}: #{e.class} #{e.message}"
      end
    end
  end

  def down
    # No-op: structured links are also the live source for new trips; we don't
    # tear them down on rollback.
  end
end
