require "rails_helper"

RSpec.describe TripGroupDecorator do
  let(:admin_user) { create(:admin_user) }
  let(:trip) { create(:trip, organiser: admin_user) }
  let(:group) { create(:trip_group, trip: trip, number: 1, volunteer_names: ["Anna"]) }
  subject(:decorated) { described_class.new(group) }

  describe "#tea" do
    before { AppSetting.instance.update!(persons_per_thermos: 7) }

    def stub_person_count(count)
      allow(decorated).to receive(:person_count).and_return(count)
    end

    it "returns 'brak' when there are no people" do
      stub_person_count(0)
      expect(decorated.tea).to eq("brak")
    end

    it "returns '1 duży termos' for 1..capacity people" do
      [1, 5, 7].each do |n|
        stub_person_count(n)
        expect(decorated.tea).to eq("1 duży termos")
      end
    end

    it "rounds up to '2 duże termosy' for 8..14 people" do
      [8, 14].each do |n|
        stub_person_count(n)
        expect(decorated.tea).to eq("2 duże termosy")
      end
    end

    it "returns '3 duże termosy' for 15..21 people" do
      stub_person_count(15)
      expect(decorated.tea).to eq("3 duże termosy")
    end

    it "uses genitive plural for 5+ thermoses" do
      stub_person_count(35)
      expect(decorated.tea).to eq("5 dużych termosów")
    end

    it "uses genitive plural for the 12..14 exception" do
      stub_person_count(78) # ceil(78/7) = 12
      expect(decorated.tea).to eq("12 dużych termosów")
    end

    it "respects the configurable persons_per_thermos capacity" do
      AppSetting.instance.update!(persons_per_thermos: 10)
      stub_person_count(11)
      expect(decorated.tea).to eq("2 duże termosy")
    end
  end
end
