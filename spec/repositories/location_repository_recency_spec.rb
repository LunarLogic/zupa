require "rails_helper"

RSpec.describe LocationRepository, "#active_with_recency" do
  let(:loc_a) { create(:location, name: "A", status: "active") }
  let(:loc_b) { create(:location, name: "B", status: "active") }
  let(:loc_c) { create(:location, name: "C", status: "inactive") }

  def published_manual_trip(date:, locations:)
    admin = create(:admin_user)
    trip = Trips::CreateDraft.new.call(organiser: admin, date: date).value!
    Trips::SaveGroupsStep.new.call(trip: trip, groups: [{location_ids: locations.map(&:id)}])
    trip.update!(status: "published")
    trip
  end

  it "returns active locations with last scheduled date from published trips" do
    published_manual_trip(date: Date.new(2026, 4, 1), locations: [loc_a, loc_b])
    published_manual_trip(date: Date.new(2026, 4, 15), locations: [loc_a])

    result = LocationRepository.new.active_with_recency
    ids_to_date = result.to_h { |r| [r[:location].id, r[:last_scheduled_at]] }

    expect(ids_to_date[loc_a.id]).to eq(Date.new(2026, 4, 15))
    expect(ids_to_date[loc_b.id]).to eq(Date.new(2026, 4, 1))
    expect(ids_to_date).not_to have_key(loc_c.id)
  end

  it "ignores draft trips" do
    admin = create(:admin_user)
    trip = Trips::CreateDraft.new.call(organiser: admin, date: Date.new(2026, 5, 1)).value!
    Trips::SaveGroupsStep.new.call(trip: trip, groups: [{location_ids: [loc_a.id]}])

    result = LocationRepository.new.active_with_recency
    row = result.find { |r| r[:location].id == loc_a.id }

    expect(row[:last_scheduled_at]).to be_nil
  end
end
