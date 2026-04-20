require "rails_helper"

RSpec.describe Trips::CreateDraft do
  it "creates a manual draft trip" do
    admin = create(:admin_user)
    result = described_class.new.call(organiser: admin, date: Date.new(2026, 4, 23))

    expect(result).to be_success
    trip = result.value!
    expect(trip).to be_persisted
    expect(trip).to be_manual
    expect(trip).to be_draft
    expect(trip.organiser).to eq(admin)
    expect(trip.date).to eq(Date.new(2026, 4, 23))
    expect(trip.source_spreadsheet_url).to be_nil
  end
end
