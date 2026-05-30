require "rails_helper"

describe Trips::TripData do
  describe "Groups parsing" do
    let(:spreadsheet) {
      double(:spreadsheet,
        rows: [
          ["GRUPA / MIEJSCA"],
          ["GR 1: Maciek*, Ela, Alex"],
          ["Półłanki 76d"],
          ["Wielicka - garaż"],
          ["GR 2: Jurek*, Kiełbasa, Ogórek"],
          ["Hallera 30"],
          ["Giedroycia 1 - garaż"]
        ])
    }

    it "wraps spreadsheet data in an object" do
      trip_data = Trips::TripData.new(date: "2025-01-01", spreadsheet: spreadsheet)
      expect(trip_data.date).to eq("2025-01-01")

      first_group = trip_data.groups.first
      expect(first_group.number).to eq("1")
      expect(first_group.volunteers).to eq(["Maciek*", "Ela", "Alex"])
      expect(first_group.destinations.map(&:value)).to eq(["Półłanki 76d", "Wielicka - garaż"])

      second_group = trip_data.groups.second
      expect(second_group.number).to eq("2")
      expect(second_group.volunteers).to eq(["Jurek*", "Kiełbasa", "Ogórek"])
      expect(second_group.destinations.map(&:value)).to eq(["Hallera 30", "Giedroycia 1 - garaż"])
    end
  end

  describe "Single row details parsing" do
    let(:spreadsheet) {
      double(:spreadsheet,
        rows: [
          ["GRUPA / MIEJSCA", "Osoby", "Liczba Osób", "Kanapki", "Zupy", "Prowiant", "Dod. Woda", "Książki", "Uwagi dodatkowe"],
          ["GR 1: Maciek*, Ela, Alex"],
          ["Półłanki 76d - garaż", nil, nil, nil, nil, nil, nil, nil, "Przyczepa zaparkowana"],
          ["Wielicka", nil, nil, nil, nil, nil, nil, nil, "Info dodatkowe"],
          ["Giedroycia 1 - pierkarnia"]
        ])
    }

    it "exposes value, address, order, and additional_info" do
      trip_data = Trips::TripData.new(date: "2025-01-01", spreadsheet: spreadsheet)

      destinations = trip_data.groups.first.destinations
      expect(destinations.map(&:value)).to eq(["Półłanki 76d - garaż", "Wielicka", "Giedroycia 1 - pierkarnia"])
      expect(destinations.map(&:address)).to eq(["Półłanki 76d", "Wielicka", "Giedroycia 1"])
      expect(destinations.map(&:order)).to eq([1, 2, 3])
      expect(destinations.map(&:additional_info)).to eq([
        "Przyczepa zaparkowana",
        "Info dodatkowe",
        ""
      ])
    end

    it "ignores legacy count columns silently for backwards compatibility with old sheets" do
      legacy_row = ["Półłanki 76d", "Ewa", "1", "2", "2", "1", "1", "Jo Nesbo", "Notes"]
      legacy_sheet = double(:spreadsheet, rows: [
        ["GRUPA / MIEJSCA"],
        ["GR 1: A"],
        legacy_row
      ])

      trip_data = Trips::TripData.new(date: "2025-01-01", spreadsheet: legacy_sheet)
      dest = trip_data.groups.first.destinations.first

      expect(dest.value).to eq("Półłanki 76d")
      expect(dest.additional_info).to eq("Notes")
      expect(dest).not_to respond_to(:sandwiches)
      expect(dest).not_to respond_to(:soups)
    end
  end
end
