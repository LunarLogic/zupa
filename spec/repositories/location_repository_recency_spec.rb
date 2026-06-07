require "rails_helper"

RSpec.describe LocationRepository do
  describe "#active_with_recency" do
    let(:admin) { create(:admin_user) }

    it "returns active locations ordered by name with recency rank and last scheduled date" do
      recent = create(:location, name: "Aaa", status: "active")
      older = create(:location, name: "Bbb", status: "active")
      create(:location, name: "Ccc", status: "active")
      create(:location, name: "Zzz inactive", status: "inactive")

      # most recent trip visits `recent`
      t1 = create(:trip, date: Date.new(2026, 6, 1), organiser: admin)
      g1 = create(:trip_group, trip: t1, volunteer_names: ["x"])
      create(:trip_destination, trip_group: g1, location: recent, order: 1)

      # previous trip visits `older`
      t2 = create(:trip, date: Date.new(2026, 5, 1), organiser: admin)
      g2 = create(:trip_group, trip: t2, volunteer_names: ["y"])
      create(:trip_destination, trip_group: g2, location: older, order: 1)

      rows = described_class.new.active_with_recency

      expect(rows.map { |r| r[:location].name }).to eq(["Aaa", "Bbb", "Ccc"])
      by_name = rows.index_by { |r| r[:location].name }
      expect(by_name["Aaa"][:recent_rank]).to eq(0)
      expect(by_name["Bbb"][:recent_rank]).to eq(1)
      expect(by_name["Ccc"][:recent_rank]).to be_nil
      expect(by_name["Aaa"][:last_scheduled_at]).to eq(Date.new(2026, 6, 1))
    end

    it "annotates person and sandwich counts for regular and estimated locations" do
      AppSetting.instance.update!(sandwiches_per_person: 2)
      regular = create(:location, name: "Regularna", status: "active")
      create(:person, location: regular, active: true, sandwiches: 5, first_name: "Ola")
      create(:animal, location: regular, active: true, name: "Mila", species: "cat")
      create(:location, name: "Grupowa", status: "active",
        location_type: "estimated", estimated_person_count: 10)

      rows = described_class.new.active_with_recency.index_by { |r| r[:location].name }

      expect(rows["Regularna"][:person_count]).to eq(1)
      expect(rows["Regularna"][:sandwich_count]).to eq(5)
      expect(rows["Regularna"][:animal_count]).to eq(1)
      expect(rows["Regularna"][:location_type]).to eq("regular")
      expect(rows["Regularna"][:people].map { |p| p[:name] }).to eq(["Ola"])
      expect(rows["Regularna"][:animals]).to eq([{name: "Mila", species: "cat"}])
      expect(rows["Regularna"][:region]).to eq(regular.region.name)
      expect(rows["Grupowa"][:person_count]).to eq(10)
      expect(rows["Grupowa"][:sandwich_count]).to eq(20)
      expect(rows["Grupowa"][:location_type]).to eq("estimated")
    end
  end

  describe "#second_to_last_trip_location_ids" do
    let(:admin) { create(:admin_user) }

    it "returns the location ids of the second-most-recent trip" do
      loc_last = create(:location, name: "Last")
      loc_prev = create(:location, name: "Prev")

      last = create(:trip, date: Date.new(2026, 6, 8), organiser: admin)
      g_last = create(:trip_group, trip: last, volunteer_names: ["a"])
      create(:trip_destination, trip_group: g_last, location: loc_last, order: 1)

      prev = create(:trip, date: Date.new(2026, 6, 1), organiser: admin)
      g_prev = create(:trip_group, trip: prev, volunteer_names: ["b"])
      create(:trip_destination, trip_group: g_prev, location: loc_prev, order: 1)

      expect(described_class.new.second_to_last_trip_location_ids).to contain_exactly(loc_prev.id)
    end

    it "returns an empty array when there are fewer than two trips" do
      expect(described_class.new.second_to_last_trip_location_ids).to eq([])
    end
  end
end
