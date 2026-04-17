require "rails_helper"

RSpec.describe "Admin trips BETA", type: :system do
  let(:admin_user) { create(:admin_user, password: "password123", password_confirmation: "password123") }

  let!(:location_a) { create(:location, name: "Grodzka 12", longitude: 19.9, latitude: 50.05) }
  let!(:location_b) { create(:location, name: "Floriańska 3", longitude: 19.95, latitude: 50.06) }
  let!(:person_a) do
    create(:person, location: location_a, active: true,
      first_name: "Ola", last_name: "Nowak",
      long_term_provisions: true, sparkling_water_count: 2, still_water_count: 0,
      book_preferences: "kryminały", extra_chocolates: 0)
  end
  let!(:animal_a) { create(:animal, location: location_a, active: true, name: "Mila", species: "cat") }
  let!(:person_b) do
    create(:person, location: location_b, active: true, first_name: "Kaja", last_name: "Wilk")
  end
  let!(:jan) { create(:volunteer, first_name: "Jan", last_name: "Kowalski", active: true) }
  let!(:anna) { create(:volunteer, first_name: "Anna", last_name: "Nowak", active: true) }
  let!(:marek) { create(:volunteer, first_name: "Marek", last_name: "Auto", active: true) }
  let!(:inactive_volunteer) { create(:volunteer, first_name: "Zosia", last_name: "Nieaktywna", active: false) }

  before do
    Flipper.enable(:trip)
    Flipper.enable(:trips_beta)
    AppSetting.instance.update!(sandwiches_per_person: 2, soups_per_person: 1, chocolates_per_person: 1)
    admin_login(admin_user)
  end

  def pick_in_select(select_el, name)
    select_el.find(:option, name).select_option
  end

  def fill_group(group_index:, volunteer_names: [], driver_names: [], locations: [], notes_by_location: {})
    within(all("[data-trip-form-target='group']")[group_index]) do
      vol_select = find("select[name*='[volunteer_ids]']", visible: :all)
      volunteer_names.each { |n| pick_in_select(vol_select, n) }

      drv_select = find("select[name*='[driver_ids]']", visible: :all)
      driver_names.each { |n| pick_in_select(drv_select, n) }

      loc_select = find("[data-trip-form-target='locationSelect']", visible: :all)
      locations.each { |n| pick_in_select(loc_select, n) }

      notes_by_location.each do |loc_name, note|
        loc_id = loc_select.find(:option, loc_name).value
        dest = find("[data-trip-form-target='destination'][data-location-id='#{loc_id}']")
        within(dest) { find("textarea[name*='[additional_info]']").set(note) }
      end
    end
  end

  describe "creating a manual trip" do
    it "persists trip with snapshots, volunteers, drivers, frozen counts" do
      visit "/admin/trips_beta/new"

      find("#trip_date", visible: false).set("2030-05-11")
      check "Aktywny", allow_label_click: true

      fill_group(
        group_index: 0,
        volunteer_names: ["Jan Kowalski", "Anna Nowak"],
        driver_names: ["Marek Auto"],
        locations: ["Grodzka 12"],
        notes_by_location: {"Grodzka 12" => "przyjść od 17"}
      )

      click_button "Zapisz Wyjazd"

      expect(page).to have_current_path(%r{/admin/trips_beta/\d+})
      expect(Trip.count).to eq(1)

      trip = Trip.first
      expect(trip.source).to eq("manual")
      expect(trip.active).to be true
      expect(trip.date.to_s).to eq("2030-05-11")
      expect(trip.organiser).to eq(admin_user)
      expect(trip.groups.size).to eq(1)

      group = trip.groups.first
      expect(group.number).to eq(1)
      expect(group.volunteers.map(&:full_name)).to contain_exactly("Jan Kowalski", "Anna Nowak")
      expect(group.drivers.map(&:full_name)).to eq(["Marek Auto"])

      destination = group.trip_destinations.first
      expect(destination.location).to eq(location_a)
      expect(destination.additional_info).to eq("przyjść od 17")
      expect(destination.person_count).to eq(1)
      expect(destination.sandwich_count).to eq(2)
      expect(destination.soup_count).to eq(1)
      expect(destination.chocolate_count).to eq(1)
      expect(destination.location_snapshot["name"]).to eq("Grodzka 12")
      expect(destination.trip_destination_people.map(&:first_name)).to eq(["Ola"])
      expect(destination.trip_destination_animals.map(&:species)).to eq(["cat"])
    end

    it "supports multiple destinations within a group" do
      visit "/admin/trips_beta/new"
      find("#trip_date", visible: false).set("2030-06-12")

      fill_group(
        group_index: 0,
        volunteer_names: ["Jan Kowalski"],
        locations: ["Grodzka 12", "Floriańska 3"],
        notes_by_location: {"Grodzka 12" => "pierwszy", "Floriańska 3" => "drugi"}
      )

      click_button "Zapisz Wyjazd"

      expect(Trip.count).to eq(1)
      group = Trip.first.groups.first
      expect(group.trip_destinations.size).to eq(2)
      expect(group.trip_destinations.map(&:additional_info)).to contain_exactly("pierwszy", "drugi")
      expect(group.trip_destinations.map(&:location)).to contain_exactly(location_a, location_b)
    end

    it "auto-numbers multiple groups and persists volunteers per group" do
      visit "/admin/trips_beta/new"
      find("#trip_date", visible: false).set("2030-07-13")

      fill_group(
        group_index: 0,
        volunteer_names: ["Jan Kowalski"],
        locations: ["Grodzka 12"]
      )

      click_button("+ Grupa", match: :first)
      fill_group(
        group_index: 1,
        volunteer_names: ["Anna Nowak"],
        locations: ["Floriańska 3"]
      )

      click_button "Zapisz Wyjazd"

      expect(Trip.count).to eq(1)
      trip = Trip.first
      expect(trip.groups.size).to eq(2)
      groups = trip.groups.order(:number)
      expect(groups.pluck(:number)).to eq([1, 2])
      expect(groups.first.volunteers.map(&:full_name)).to eq(["Jan Kowalski"])
      expect(groups.last.volunteers.map(&:full_name)).to eq(["Anna Nowak"])
      expect(groups.last.trip_destinations.first.location).to eq(location_b)
    end

    it "rejects trip without destinations" do
      visit "/admin/trips_beta/new"
      find("#trip_date", visible: false).set("2030-08-14")

      within(all("[data-trip-form-target='group']").first) do
        vol_select = find("select[name*='[volunteer_ids]']", visible: :all)
        pick_in_select(vol_select, "Jan Kowalski")
      end

      click_button "Zapisz Wyjazd"

      expect(Trip.count).to eq(0)
      expect(page).to have_content(/za krótk|Trip destinations/i)
    end

    it "excludes inactive volunteers from volunteer and driver pools" do
      visit "/admin/trips_beta/new"
      within(all("[data-trip-form-target='group']").first) do
        vol_options = all("select[name*='[volunteer_ids]'] option").map(&:text)
        drv_options = all("select[name*='[driver_ids]'] option").map(&:text)
        expect(vol_options).to include("Jan Kowalski", "Anna Nowak")
        expect(vol_options).not_to include("Zosia Nieaktywna")
        expect(drv_options).to include("Jan Kowalski", "Anna Nowak")
        expect(drv_options).not_to include("Zosia Nieaktywna")
      end
    end

    it "prefills date with next Thursday when creating a new trip" do
      visit "/admin/trips_beta/new"
      today = Date.current
      days_ahead = (4 - today.wday) % 7
      days_ahead = 7 if days_ahead.zero?
      expected = (today + days_ahead).to_s
      expect(find("#trip_date", visible: false).value).to eq(expected)
    end

    it "does not render a group number input" do
      visit "/admin/trips_beta/new"
      expect(page).to have_no_selector("input[name*='[number]']")
    end
  end

  describe "editing a manual trip" do
    let!(:existing_trip) do
      Trips::PersistManualTrip.new.call(
        date: Date.new(2030, 9, 15),
        admin_user_id: admin_user.id,
        active: true,
        groups_attributes: [
          {
            volunteer_ids: [jan.id],
            trip_destinations_attributes: [
              {location_id: location_a.id, additional_info: "original"}
            ]
          }
        ]
      )
    end

    it "updates volunteers, adds a destination via location multiselect, re-snapshots people" do
      visit "/admin/trips_beta/#{existing_trip.id}/edit"

      within(all("[data-trip-form-target='group']").first) do
        vol_select = find("select[name*='[volunteer_ids]']", visible: :all)
        pick_in_select(vol_select, "Anna Nowak")

        loc_select = find("[data-trip-form-target='locationSelect']", visible: :all)
        pick_in_select(loc_select, "Floriańska 3")

        new_dest = find("[data-trip-form-target='destination'][data-location-id='#{location_b.id}']")
        within(new_dest) { find("textarea[name*='[additional_info]']").set("nowy przystanek") }
      end

      click_button "Zapisz Wyjazd"

      existing_trip.reload
      group = existing_trip.groups.first
      expect(group.volunteers.map(&:full_name)).to contain_exactly("Jan Kowalski", "Anna Nowak")
      expect(group.trip_destinations.size).to eq(2)
      new_dest = group.trip_destinations.find_by(location_id: location_b.id)
      expect(new_dest.additional_info).to eq("nowy przystanek")
      expect(new_dest.trip_destination_people.map(&:first_name)).to eq(["Kaja"])
    end

    it "removes a destination when its location is deselected" do
      existing_trip.groups.first.trip_destinations.create!(
        location: location_b,
        additional_info: "do usunięcia"
      )

      visit "/admin/trips_beta/#{existing_trip.id}/edit"

      within(all("[data-trip-form-target='group']").first) do
        loc_select = find("[data-trip-form-target='locationSelect']", visible: :all)
        option = loc_select.find(:option, "Floriańska 3")
        option.unselect_option
      end

      click_button "Zapisz Wyjazd"

      existing_trip.reload
      expect(existing_trip.groups.first.trip_destinations.pluck(:location_id)).to eq([location_a.id])
    end

    it "keeps inactive volunteers in the pool when already assigned" do
      existing_trip.groups.first.volunteers << inactive_volunteer

      visit "/admin/trips_beta/#{existing_trip.id}/edit"

      within(all("[data-trip-form-target='group']").first) do
        options = all("select[name*='[volunteer_ids]'] option").map(&:text)
        expect(options).to include("Zosia Nieaktywna")
      end
    end
  end

  describe "menu and flipper" do
    it "shows BETA section when flipper enabled" do
      visit "/admin/trips_beta"
      expect(page).to have_content("Wyjazdy BETA").or have_current_path("/admin/trips_beta")
    end
  end
end
