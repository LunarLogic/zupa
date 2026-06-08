namespace :volunteers do
  # "ZUPOWÓZ" is a car marker admins typed into the volunteer cell, not a person.
  # SyncGroupVolunteers turned those cells into bogus Volunteer rows (and stray
  # punctuation/diacritic variants). These tasks find and remove that junk.
  #
  # IMPORTANT: for SHEET trips the displayed volunteers come from the raw
  # volunteer_names text column, NOT these structured Volunteer links — so
  # removing a junk Volunteer (and its group links) does not change any past
  # sheet trip. We therefore only auto-remove rows not used by any MANUAL trip.
  zupowoz = -> { Volunteer.where("first_name ILIKE :q OR last_name ILIKE :q", q: "%zupow%") }

  desc "Read-only: list ZUPOWÓZ-like volunteers and their trip associations"
  task audit_junk: :environment do
    junk = zupowoz.call
    puts "Found #{junk.count} ZUPOWÓZ-like volunteers:\n\n"
    junk.find_each do |v|
      trips = (v.trip_groups + v.driving_groups).map(&:trip).uniq
      manual = trips.select(&:manual?)
      sheet = trips.select(&:sheet?)
      flag = manual.any? ? "  ⚠️ MANUAL trips #{manual.map(&:id)} (would change display)" : "  ✓ safe"
      puts format("  #%-5d %-32s helper:%-2d driver:%-2d  sheet:%-2d manual:%-2d%s",
        v.id, v.full_name, v.trip_groups.size, v.driving_groups.size, sheet.size, manual.size, flag)
    end
    puts "\nRun `rake volunteers:cleanup_zupowoz` (dry-run) to preview removal."
  end

  desc "Remove ZUPOWÓZ junk volunteers not used by any MANUAL trip. DRY_RUN=0 to apply."
  task cleanup_zupowoz: :environment do
    dry = ENV["DRY_RUN"] != "0"
    removed = 0
    skipped = []

    zupowoz = Volunteer.where("first_name ILIKE :q OR last_name ILIKE :q", q: "%zupow%")
    zupowoz.find_each do |v|
      trips = (v.trip_groups + v.driving_groups).map(&:trip).uniq
      if trips.any?(&:manual?)
        skipped << v.id
        next
      end

      puts "#{dry ? "[dry-run] would remove" : "removing"} ##{v.id} #{v.full_name.inspect}"
      unless dry
        ActiveRecord::Base.transaction do
          v.trip_groups.clear   # drop helper join rows (sheet display untouched)
          v.driving_groups.clear # drop driver join rows
          v.destroy!
        end
      end
      removed += 1
    end

    puts "\n#{dry ? "Would remove" : "Removed"}: #{removed}"
    puts "Skipped (linked to a manual trip — review by hand): #{skipped}" if skipped.any?
    puts "\nDRY RUN — set DRY_RUN=0 to apply." if dry
  end
end
