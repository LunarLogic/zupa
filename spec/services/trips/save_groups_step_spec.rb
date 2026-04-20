require "rails_helper"

RSpec.describe Trips::SaveGroupsStep do
  let(:admin) { create(:admin_user) }
  let(:region) { create(:region) }
  let(:loc1) { create(:location, region: region, status: "active") }
  let(:loc2) { create(:location, region: region, status: "active") }
  let(:loc3) { create(:location, region: region, status: "active") }
  let(:trip) { Trips::CreateDraft.new.call(organiser: admin, date: Date.tomorrow).value! }

  it "creates groups with destinations and auto-numbers them" do
    result = described_class.new.call(trip: trip, groups: [
      {location_ids: [loc1.id, loc2.id]},
      {location_ids: [loc3.id]}
    ])

    expect(result).to be_success
    trip.reload
    expect(trip.groups.size).to eq(2)
    expect(trip.groups.pluck(:number)).to eq([1, 2])
    expect(trip.groups.first.trip_destinations.map(&:location_id)).to contain_exactly(loc1.id, loc2.id)
    expect(trip.groups.last.trip_destinations.map(&:location_id)).to eq([loc3.id])
  end

  it "replaces existing groups on subsequent call" do
    described_class.new.call(trip: trip, groups: [{location_ids: [loc1.id]}])
    result = described_class.new.call(trip: trip, groups: [{location_ids: [loc2.id]}])

    expect(result).to be_success
    expect(trip.reload.groups.size).to eq(1)
    expect(trip.groups.first.trip_destinations.map(&:location_id)).to eq([loc2.id])
  end

  it "preserves volunteer assignments across save when group index unchanged" do
    vol = create(:volunteer)
    drv = create(:volunteer)

    described_class.new.call(trip: trip, groups: [{location_ids: [loc1.id]}])
    group = trip.reload.groups.first
    group.volunteers = [vol]
    group.drivers = [drv]

    described_class.new.call(trip: trip, groups: [{location_ids: [loc1.id, loc2.id]}])

    trip.reload
    new_group = trip.groups.first
    expect(new_group.volunteer_ids).to eq([vol.id])
    expect(new_group.driver_ids).to eq([drv.id])
  end

  it "skips groups with no locations" do
    result = described_class.new.call(trip: trip, groups: [
      {location_ids: []},
      {location_ids: [loc1.id]}
    ])

    expect(result).to be_success
    expect(trip.reload.groups.size).to eq(1)
    expect(trip.groups.first.number).to eq(1)
  end
end
