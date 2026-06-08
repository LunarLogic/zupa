require "rails_helper"

RSpec.describe "Admin trip ownership (sheet vs wizard)", type: :system do
  let(:admin_user) { create(:admin_user, password: "password123", password_confirmation: "password123") }
  let(:location) { create(:location, name: "Schronisko") }

  before { admin_login(admin_user) }

  context "a wizard-managed trip" do
    let(:trip) do
      t = create(:trip, date: Date.tomorrow, organiser: admin_user, source: "manual",
        source_spreadsheet_url: "https://docs.google.com/spreadsheets/d/leftover")
      g = create(:trip_group, trip: t, number: 1, volunteer_names: ["Ola"])
      create(:trip_destination, trip_group: g, location: location)
      t
    end

    before { trip }

    it "hides the spreadsheet URL and offers wizard editing without a switch confirm" do
      visit "/admin/trips/#{trip.id}"

      expect(page).not_to have_field("trip[source_spreadsheet_url]")
      link = find_link(I18n.t("admin.trips.edit_in_wizard.button"))
      expect(link["data-confirm"]).to be_blank
    end

    it "saves metadata only — does not re-parse or rebuild groups" do
      original_group_ids = trip.groups.map(&:id)

      visit "/admin/trips/#{trip.id}"
      click_button "Zapisz Wyjazd"

      trip.reload
      expect(trip.groups.map(&:id)).to match_array(original_group_ids)
      expect(trip.source).to eq("manual")
    end

    it "shows a validation error instead of crashing when a required field is blank" do
      visit "/admin/trips/#{trip.id}"
      page.execute_script("document.getElementById('trip_date').value = ''")
      click_button "Zapisz Wyjazd"

      # No 500 — redirects back, trip keeps its date (update rejected).
      expect(page).to have_current_path(%r{/admin/trips/#{trip.id}}, wait: 5)
      expect(trip.reload.date).to be_present
    end
  end

  context "a sheet-managed trip" do
    let(:trip) do
      create(:trip, date: Date.tomorrow, organiser: admin_user, source: "sheet",
        source_spreadsheet_url: "https://docs.google.com/spreadsheets/d/abc")
    end

    before { trip }

    it "shows the spreadsheet URL and warns before switching to the wizard (one-way)" do
      visit "/admin/trips/#{trip.id}"

      expect(page).to have_field("trip[source_spreadsheet_url]")
      link = find_link(I18n.t("admin.trips.switch_to_wizard.button"))
      expect(link["data-confirm"]).to eq(I18n.t("admin.trips.switch_to_wizard.confirm"))
    end
  end
end
