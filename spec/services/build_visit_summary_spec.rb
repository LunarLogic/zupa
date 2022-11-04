require "rails_helper"

RSpec.describe BuildVisitSummary do
  let(:location) { create(:location, name: "test") }
  let!(:people) { create_list(:person, 3, location: location) }
  let(:params) { {location_id: location.id, author: "Author", content: "Content", visit_date: Date.today - 1.week} }
  describe "#call" do
    it "returns a visit summary object with people from the visit summary location" do
      visit_summary = described_class.new(params).call

      expect(visit_summary).to be_an_instance_of(VisitSummary)
      expect(visit_summary.people).to eq(Location.includes(:people).find_by_name("test").people)
    end
  end
end
