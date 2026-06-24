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

    context "when the location is a group (estimated) location with a legacy inactive person attached" do
      let(:group_location) { create(:location, name: "group") }
      let(:params) { {location_id: group_location.id, author: "Author", content: "Content", visit_date: Date.today - 1.week} }

      before do
        # Replicate legacy prod state: an inactive person attached to a location
        # that was later converted to estimated, bypassing validations.
        create(:person, :inactive, location: group_location)
        group_location.update_columns(location_type: "estimated", estimated_person_count: 5)
      end

      it "builds a visit summary that can be saved (excludes the inactive person)" do
        visit_summary = described_class.new(params).call

        expect(visit_summary.save).to be(true)
        expect(visit_summary.people).to be_empty
      end
    end
  end
end
