require "rails_helper"

RSpec.describe TripGroup, type: :model do
  describe "#all_volunteer_names" do
    context "for a sheet trip" do
      it "returns the free-text volunteer_names array" do
        trip = create(:trip) # sheet by default
        group = create(:trip_group, trip: trip, volunteer_names: ["Misia", "Kasia"])

        expect(group.all_volunteer_names).to eq(["Misia", "Kasia"])
      end

      it "returns an empty array when volunteer_names is nil" do
        trip = create(:trip)
        group = create(:trip_group, trip: trip, volunteer_names: nil)

        expect(group.all_volunteer_names).to eq([])
      end
    end

    context "for a manual trip" do
      it "lists drivers marked with a trailing * followed by helpers" do
        trip = create(:trip, :manual)
        group = create(:trip_group, trip: trip, volunteer_names: nil)
        driver = create(:volunteer, first_name: "Ola", last_name: "Driver")
        helper = create(:volunteer, first_name: "Ela", last_name: "Helper")
        group.drivers << driver
        group.volunteers << helper

        expect(group.all_volunteer_names).to eq(["Ola Driver*", "Ela Helper"])
      end
    end
  end

  describe "#volunteer_count" do
    it "counts structured volunteers and drivers for a manual trip" do
      trip = create(:trip, :manual)
      group = create(:trip_group, trip: trip, volunteer_names: nil)
      group.drivers << create(:volunteer)
      group.volunteers << create(:volunteer)

      expect(group.volunteer_count).to eq(2)
    end

    it "counts free-text names for a sheet trip" do
      group = create(:trip_group, trip: create(:trip), volunteer_names: ["A", "B", "C"])
      expect(group.volunteer_count).to eq(3)
    end
  end

  describe "aggregate counts sum over destinations" do
    it "sums water/provision/book counts without raising" do
      group = create(:trip_group, trip: create(:trip))
      # regression: these used sum(*:symbol) which raised
      expect { group.water_count }.not_to raise_error
      expect { group.provision_count }.not_to raise_error
      expect { group.book_count }.not_to raise_error
    end
  end
end
