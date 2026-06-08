require "rails_helper"

RSpec.describe Trips::SyncGroupVolunteers do
  let(:trip) { create(:trip) }
  let(:group) { create(:trip_group, trip: trip, volunteer_names: nil) }

  it "creates volunteers and links them as drivers (*) and helpers" do
    described_class.new.call(group: group, names: ["Jan Kowalski*", "Ela", "Alex"])

    jan = Volunteer.find_by(first_name: "Jan", last_name: "Kowalski")
    ela = Volunteer.find_by(first_name: "Ela", last_name: "n/a")
    alex = Volunteer.find_by(first_name: "Alex", last_name: "n/a")

    expect(group.reload.drivers).to contain_exactly(jan)
    expect(group.volunteers).to contain_exactly(ela, alex)
  end

  it "guesses gender: ends in 'a' or 'Dai' is female, otherwise male" do
    described_class.new.call(group: group, names: ["Ela", "Maciek", "Dai", "Anna Nowak"])

    expect(Volunteer.find_by(first_name: "Ela").gender).to eq("female")
    expect(Volunteer.find_by(first_name: "Maciek").gender).to eq("male")
    expect(Volunteer.find_by(first_name: "Dai").gender).to eq("female")
    expect(Volunteer.find_by(first_name: "Anna").gender).to eq("female")
  end

  it "ignores the ZUPOWÓZ car marker and its dangling connectors" do
    described_class.new.call(group: group, names: [
      "ZUPOWÓZ", "Basta + ZUPOWÓZ", "A Paszek ZUPOWÓZ", "Beháňová i Zupowóz", "A Paszek,"
    ])

    names = group.reload.volunteers.map(&:full_name)
    expect(names).to contain_exactly("Basta n/a", "A Paszek", "Beháňová n/a")
    expect(Volunteer.where("first_name ILIKE ? OR last_name ILIKE ?", "%zupow%", "%zupow%")).to be_empty
  end

  it "is idempotent across re-parses (no duplicates, no validation error)" do
    names = ["Jan Kowalski*", "Ela", "Łukasz Mazur"]
    described_class.new.call(group: group, names: names)

    other_group = create(:trip_group, trip: create(:trip), volunteer_names: nil)
    expect {
      described_class.new.call(group: other_group, names: names)
    }.not_to change(Volunteer, :count)
  end

  it "reuses existing volunteers (case-insensitive) without changing their gender" do
    existing = create(:volunteer, first_name: "Ela", last_name: "n/a", gender: "male")

    expect {
      described_class.new.call(group: group, names: ["ela"])
    }.not_to change(Volunteer, :count)

    expect(group.reload.volunteers).to contain_exactly(existing)
    expect(existing.reload.gender).to eq("male")
  end
end
