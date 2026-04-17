require "rails_helper"

RSpec.describe Trips::PersistManualTrip do
  let(:app_setting) { AppSetting.instance }
  let(:admin) { create(:admin_user) }
  let(:location) { create(:location, name: "Grodzka 12", longitude: 19.9, latitude: 50.05) }
  let!(:person) do
    create(:person, location: location, active: true,
      first_name: "Ola", last_name: "Nowak",
      long_term_provisions: true, sparkling_water_count: 2)
  end
  let!(:animal) { create(:animal, location: location, active: true, name: "Mila", species: "cat") }
  let(:jan) { create(:volunteer, first_name: "Jan", last_name: "Kowalski") }
  let(:anna) { create(:volunteer, first_name: "Anna", last_name: "Nowak") }

  before do
    app_setting.update!(sandwiches_per_person: 2, soups_per_person: 1, chocolates_per_person: 1)
  end

  it "creates a manual trip with snapshotted destinations and auto-numbers groups" do
    params = {
      date: Date.tomorrow,
      admin_user_id: admin.id,
      active: true,
      groups_attributes: [
        {
          volunteer_ids: [jan.id, anna.id],
          trip_destinations_attributes: [
            {location_id: location.id, additional_info: "przyjść od 17"}
          ]
        }
      ]
    }

    trip = described_class.new.call(params)

    expect(trip).to be_persisted
    expect(trip.source).to eq("manual")
    expect(trip.source_spreadsheet_url).to be_nil
    expect(trip.groups.size).to eq(1)

    group = trip.groups.first
    expect(group.number).to eq(1)
    expect(group.volunteers.map(&:full_name)).to contain_exactly("Jan Kowalski", "Anna Nowak")
    expect(group.all_volunteer_names).to contain_exactly("Jan Kowalski", "Anna Nowak")

    destination = group.trip_destinations.first
    expect(destination.location_id).to eq(location.id)
    expect(destination.additional_info).to eq("przyjść od 17")
    expect(destination.person_count).to eq(1)
    expect(destination.sandwich_count).to eq(2)
    expect(destination.soup_count).to eq(1)
    expect(destination.chocolate_count).to eq(1)
    expect(destination.location_snapshot["name"]).to eq("Grodzka 12")

    expect(destination.trip_destination_people.map(&:first_name)).to eq(["Ola"])
    expect(destination.trip_destination_animals.map(&:species)).to eq(["cat"])
  end

  it "fails if no groups" do
    params = {date: Date.tomorrow, admin_user_id: admin.id, active: true, groups_attributes: []}
    expect { described_class.new.call(params) }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "fails if group has no destinations" do
    params = {
      date: Date.tomorrow,
      admin_user_id: admin.id,
      active: true,
      groups_attributes: [
        {volunteer_ids: [jan.id], trip_destinations_attributes: []}
      ]
    }
    expect { described_class.new.call(params) }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
