require "rails_helper"
require Rails.root.join("db/migrate/20260530120002_backfill_trip_destination_people.rb")

RSpec.describe BackfillTripDestinationPeople do
  let(:trip) { create(:trip) }
  let(:group) { create(:trip_group, trip: trip) }

  before { TripDestinationPerson.delete_all }

  describe "regular location" do
    let(:location) { create(:location, location_type: "regular") }
    let!(:alice) do
      create(:person, location: location, active: true,
        first_name: "Alice", last_name: "Smith",
        soups: 2, sandwiches: 3, chocolates: 4,
        sparkling_water: 1, still_water: 2,
        long_term_provisions: true, book_preferences: "scifi")
    end
    let!(:bob) do
      create(:person, location: location, active: true,
        first_name: "Bob",
        soups: 1, sandwiches: 1, chocolates: 0,
        long_term_provisions: false)
    end

    context "when location_snapshot has active_people_ids" do
      let!(:trip_destination) do
        create(:trip_destination,
          trip_group: group, location: location,
          skip_snapshot: true,
          location_snapshot: {"active_people_ids" => [alice.id, bob.id]})
      end

      before { trip_destination.trip_destination_people.delete_all }

      it "creates trip_destination_people from snapshot ids" do
        described_class.new.up
        trip_destination.reload

        expect(trip_destination.trip_destination_people.count).to eq 2
        names = trip_destination.trip_destination_people.pluck(:first_name)
        expect(names).to contain_exactly("Alice", "Bob")
      end

      it "copies per-person fields from current Person rows" do
        described_class.new.up

        snap_alice = trip_destination.trip_destination_people.find_by(first_name: "Alice")
        expect(snap_alice).to have_attributes(
          last_name: "Smith",
          soups: 2, sandwiches: 3, chocolates: 4,
          sparkling_water: 1, still_water: 2,
          long_term_provisions: true,
          book_preferences: "scifi"
        )
      end

      it "populates chocolates and person_count columns on the trip_destination" do
        described_class.new.up

        trip_destination.reload
        expect(trip_destination.chocolates).to eq 4
        expect(trip_destination.person_count).to eq 2
      end

      it "preserves historical sheet-sourced columns (soups, sandwiches, waters, provisions, books)" do
        trip_destination.update_columns(
          soups: 77, sandwiches: 88, waters: 99,
          provisions: 11, books: 22
        )

        described_class.new.up

        trip_destination.reload
        expect(trip_destination).to have_attributes(
          soups: 77, sandwiches: 88, waters: 99,
          provisions: 11, books: 22
        )
      end

      it "is idempotent" do
        described_class.new.up
        described_class.new.up

        expect(trip_destination.trip_destination_people.count).to eq 2
      end
    end

    context "when location_snapshot is missing (pre-PR#2 trips)" do
      let!(:trip_destination) do
        create(:trip_destination,
          trip_group: group, location: location,
          skip_snapshot: true,
          location_snapshot: nil)
      end

      before { trip_destination.trip_destination_people.delete_all }

      it "falls back to current location.active_people" do
        described_class.new.up

        expect(trip_destination.trip_destination_people.count).to eq 2
      end
    end

    context "when a snapshotted person was deleted from the database" do
      let!(:trip_destination) do
        ids = [alice.id, bob.id, 999_999]
        create(:trip_destination,
          trip_group: group, location: location,
          skip_snapshot: true,
          location_snapshot: {"active_people_ids" => ids})
      end

      before { trip_destination.trip_destination_people.delete_all }

      it "inserts a placeholder row for the missing person" do
        described_class.new.up

        rows = trip_destination.trip_destination_people
        expect(rows.count).to eq 3
        placeholder = rows.find_by(person_id: nil)
        expect(placeholder.first_name).to eq "(deleted)"
      end
    end
  end

  describe "estimated location" do
    let(:location) do
      create(:location, location_type: "estimated", estimated_person_count: 8)
    end
    let!(:trip_destination) do
      create(:trip_destination,
        trip_group: group, location: location, skip_snapshot: true)
    end

    before do
      AppSetting.instance.update!(chocolates_per_person: 2)
      trip_destination.trip_destination_people.delete_all
    end

    it "sets chocolates = estimated_person_count * AppSetting.chocolates_per_person" do
      described_class.new.up

      trip_destination.reload
      expect(trip_destination.chocolates).to eq 16
    end

    it "sets person_count = estimated_person_count" do
      described_class.new.up

      trip_destination.reload
      expect(trip_destination.person_count).to eq 8
    end

    it "does not create any trip_destination_people" do
      described_class.new.up

      expect(trip_destination.trip_destination_people).to be_empty
    end
  end
end
