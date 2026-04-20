require "rails_helper"

RSpec.describe Trips::SaveVolunteersStep do
  let(:admin) { create(:admin_user) }
  let(:loc) { create(:location) }
  let(:trip) do
    t = Trips::CreateDraft.new.call(organiser: admin, date: Date.tomorrow).value!
    Trips::SaveGroupsStep.new.call(trip: t, groups: [{location_ids: [loc.id]}])
    t.reload
  end

  it "assigns volunteers and drivers to groups" do
    vol = create(:volunteer)
    drv = create(:volunteer)
    group = trip.groups.first

    result = described_class.new.call(trip: trip, assignments: {
      group.id.to_s => {volunteer_ids: [vol.id], driver_ids: [drv.id]}
    })

    expect(result).to be_success
    expect(group.reload.volunteer_ids).to eq([vol.id])
    expect(group.driver_ids).to eq([drv.id])
  end

  it "clears assignments when ids empty" do
    vol = create(:volunteer)
    group = trip.groups.first
    group.volunteers = [vol]

    described_class.new.call(trip: trip, assignments: {
      group.id.to_s => {volunteer_ids: [], driver_ids: []}
    })

    expect(group.reload.volunteers).to be_empty
  end
end
