require "rails_helper"

RSpec.describe Trips::UpdateBasic do
  it "updates date and organiser" do
    admin1 = create(:admin_user)
    admin2 = create(:admin_user)
    trip = Trips::CreateDraft.new.call(organiser: admin1, date: Date.new(2026, 4, 23)).value!

    result = described_class.new.call(trip: trip, date: Date.new(2026, 4, 30), organiser: admin2)

    expect(result).to be_success
    expect(trip.reload.date).to eq(Date.new(2026, 4, 30))
    expect(trip.organiser).to eq(admin2)
  end
end
