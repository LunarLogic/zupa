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
          ["Półłanki 76d - garaż", "Ewa", "1", "2", "2", "1", "1", "coś Jo Nesbo", "Przyczepa zaparkowana"],
          ["Wielicka", "Ewa", "1", "2", "TAK", "3", "4", "",	"Info dodatkowe"],
          ["Giedroycia 1 - pierkarnia", "Ewa;Andrzej;Bartek", "3", "6;Z masłem", "2;Ewa i Bartek", "Andrzej", "TAK - GAZOWANA", "2;Ewa - kryminał, Andrzej - poezja", "Info dodatkowe"],
          ["Giedroycia 2 - pierkarnia", "Ewa;Andrzej;Bartek", "3", "6", "2", "", "", "",	""]
        ])
    }

    it "wraps spreadsheet data in an object" do
      trip_data = Trips::TripData.new(date: "2025-01-01", spreadsheet: spreadsheet)

      first_group = trip_data.groups.first
      destination1 = first_group.destinations.first
      expect(destination1.value).to eq "Półłanki 76d - garaż"
      expect(destination1.address).to eq "Półłanki 76d"
      expect(destination1.sandwiches).to eq 2
      expect(destination1.soups).to eq 2
      expect(destination1.provisions).to eq 1
      expect(destination1.waters).to eq 1
      expect(destination1.books).to eq 1
      expect(destination1.order).to eq 1
      expect(destination1.additional_info).to eq "Przyczepa zaparkowana"

      destination2 = first_group.destinations.second
      expect(destination2.value).to eq "Wielicka"
      expect(destination2.address).to eq "Wielicka"
      expect(destination2.sandwiches).to eq 2
      expect(destination2.soups).to eq 1
      expect(destination2.provisions).to eq 3
      expect(destination2.waters).to eq 4
      expect(destination2.books).to eq 0
      expect(destination2.order).to eq 2
      expect(destination2.additional_info).to eq "Info dodatkowe"

      destination3 = first_group.destinations[2]
      expect(destination3.sandwiches).to eq 6
      expect(destination3.soups).to eq 2
      expect(destination3.provisions).to eq 1
      expect(destination3.waters).to eq 1
      expect(destination3.books).to eq 2
      expect(destination3.order).to eq 3
      expect(destination3.additional_info).to eq "Info dodatkowe"

      destination4 = first_group.destinations[3]
      expect(destination4.additional_info).to eq ""
      expect(destination4.order).to eq 4
    end
  end
end
