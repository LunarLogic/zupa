require "rails_helper"

RSpec.describe Trips::CreateManualTrip do
  let(:admin) { create(:admin_user) }
  let(:location_a) { create(:location, name: "Miejsce A") }
  let(:location_b) { create(:location, name: "Miejsce B") }
  let!(:person) { create(:person, location: location_a, active: true, sandwiches: 4, soups: 2) }
  let(:driver) { create(:volunteer, first_name: "Ola", last_name: "Kierowca") }
  let(:helper) { create(:volunteer, first_name: "Ela", last_name: "Pomocnik") }

  def valid_groups
    [
      {location_ids: [location_a.id, location_b.id], driver_ids: [driver.id], volunteer_ids: [helper.id]}
    ]
  end

  it "creates a manual trip with groups, ordered destinations and snapshots" do
    result = described_class.new.call(date: Date.new(2026, 7, 1), organiser: admin, groups: valid_groups)

    expect(result).to be_success
    trip = result.value!
    expect(trip.source).to eq("manual")
    expect(trip.organiser).to eq(admin)

    group = trip.groups.first
    expect(group.number).to eq(1)
    expect(group.trip_destinations.pluck(:order)).to eq([1, 2])
    expect(group.trip_destinations.map(&:location)).to eq([location_a, location_b])
  end

  it "stores per-location additional info" do
    groups = [{location_ids: [location_a.id, location_b.id], additional_info: {location_a.id => "Kod do bramy"}}]
    result = described_class.new.call(date: Date.new(2026, 7, 1), organiser: admin, groups: groups)

    destinations = result.value!.groups.first.trip_destinations
    expect(destinations.find_by(location: location_a).additional_info).to eq("Kod do bramy")
    expect(destinations.find_by(location: location_b).additional_info).to eq("")
  end

  it "creates a volo access code valid until the day after the trip" do
    result = described_class.new.call(
      date: Date.new(2026, 7, 1), organiser: admin, groups: valid_groups, access_code: "zupa1234"
    )

    code = result.value!.auth_code
    expect(code.value).to eq("zupa1234")
    expect(code.expires_at.to_date).to eq(Date.new(2026, 7, 2))
    expect(code.valid_from.to_date).to eq(Date.new(2026, 6, 30)) # day before the trip
  end

  it "creates no access code when blank" do
    result = described_class.new.call(
      date: Date.new(2026, 7, 1), organiser: admin, groups: valid_groups, access_code: ""
    )
    expect(result.value!.auth_code).to be_nil
  end

  it "freezes a per-person snapshot at creation" do
    result = described_class.new.call(date: Date.new(2026, 7, 1), organiser: admin, groups: valid_groups)
    destination = result.value!.groups.first.trip_destinations.find_by(location: location_a)

    expect(destination.trip_destination_people.count).to eq(1)
    expect(destination.sandwich_count).to eq(4)
  end

  it "assigns structured drivers and helpers" do
    group = described_class.new.call(date: Date.new(2026, 7, 1), organiser: admin, groups: valid_groups).value!.groups.first

    expect(group.drivers).to contain_exactly(driver)
    expect(group.volunteers).to contain_exactly(helper)
    expect(group.all_volunteer_names).to eq(["Ola Kierowca*", "Ela Pomocnik"])
  end

  it "treats a volunteer assigned as both driver and helper as a driver only" do
    groups = [{location_ids: [location_a.id], driver_ids: [driver.id], volunteer_ids: [driver.id, helper.id]}]
    group = described_class.new.call(date: Date.new(2026, 7, 1), organiser: admin, groups: groups).value!.groups.first

    expect(group.drivers).to contain_exactly(driver)
    expect(group.volunteers).to contain_exactly(helper)
  end

  describe "validation" do
    it "fails without a date" do
      result = described_class.new.call(date: nil, organiser: admin, groups: valid_groups)
      expect(result).to be_failure
    end

    it "fails without an organiser" do
      result = described_class.new.call(date: Date.new(2026, 7, 1), organiser: nil, groups: valid_groups)
      expect(result).to be_failure
    end

    it "fails when no group has any location" do
      result = described_class.new.call(date: Date.new(2026, 7, 1), organiser: admin,
        groups: [{location_ids: [], driver_ids: [], volunteer_ids: []}])
      expect(result).to be_failure
    end

    it "persists nothing on failure" do
      expect {
        described_class.new.call(date: nil, organiser: admin, groups: valid_groups)
      }.not_to change { Trip.count }
    end
  end
end
