require "rails_helper"

RSpec.describe Trips::PublishTrip do
  let(:admin) { create(:admin_user) }
  let(:loc) { create(:location) }

  def build_trip_with_groups
    trip = Trips::CreateDraft.new.call(organiser: admin, date: Date.tomorrow).value!
    Trips::SaveGroupsStep.new.call(trip: trip, groups: [{location_ids: [loc.id]}])
    trip.reload
  end

  it "publishes a draft with groups + destinations" do
    trip = build_trip_with_groups

    result = described_class.new.call(trip: trip)

    expect(result).to be_success
    expect(trip.reload).to be_published
  end

  it "fails when trip has no groups" do
    trip = Trips::CreateDraft.new.call(organiser: admin, date: Date.tomorrow).value!

    result = described_class.new.call(trip: trip)

    expect(result).to be_failure
    expect(trip.reload).to be_draft
  end

  it "fails when a group has no destinations" do
    trip = build_trip_with_groups
    trip.groups.first.trip_destinations.destroy_all

    result = described_class.new.call(trip: trip.reload)

    expect(result).to be_failure
    expect(trip.reload).to be_draft
  end

  it "refreshes people and animal snapshots on publish" do
    trip = build_trip_with_groups
    person = create(:person, location: loc, active: true)
    animal = create(:animal, location: loc, active: true)

    described_class.new.call(trip: trip)

    destination = trip.reload.groups.first.trip_destinations.first
    expect(destination.trip_destination_people.map(&:person_id)).to include(person.id)
    expect(destination.trip_destination_animals.map(&:name)).to include(animal.name)
  end
end
