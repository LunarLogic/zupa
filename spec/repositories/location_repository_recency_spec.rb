require "rails_helper"

RSpec.describe LocationRepository do
  describe "#active_with_recency" do
    let(:admin) { create(:admin_user) }

    it "returns active locations ordered by name with recency rank and last scheduled date" do
      recent = create(:location, name: "Aaa", status: "active")
      older = create(:location, name: "Bbb", status: "active")
      never = create(:location, name: "Ccc", status: "active")
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
  end
end
