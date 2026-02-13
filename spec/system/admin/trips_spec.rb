require "rails_helper"

RSpec.describe "Admin trips preparations", type: :system do
  let(:admin_user) { create(:admin_user, password: "password123", password_confirmation: "password123") }

  let(:default_template) do
    create(:preparation_template, :default,
      name: "Domyślny szablon",
      content_html: "<h1>Przygotowania na wyjazd</h1><p>Data: {{date}}</p><p>Organizator: {{organiser}}</p>")
  end

  let(:other_template) do
    create(:preparation_template,
      name: "Inny szablon",
      content_html: "<h2>Inny szablon</h2><p>Data: {{date}}</p>")
  end

  let(:trip) do
    create(:trip, date: "2025-12-01", organiser: admin_user, preparation_template: default_template).tap do |t|
      create(:trip_group, trip: t, number: 1, volunteers: ["Anna", "Bartek"])
    end
  end

  let(:trip_without_template) do
    create(:trip, date: "2025-11-15", organiser: admin_user, preparation_template: nil)
  end

  before do
    default_template
    other_template
    trip
    trip_without_template
    admin_login(admin_user)
  end

  describe "Trips index" do
    it "shows template name column" do
      visit "/admin/trips"

      expect(page).to have_content("Szablon")
      expect(page).to have_content("Domyślny szablon")
    end

    it "shows 'Brak' for trip without template" do
      visit "/admin/trips"

      row = find("tr", text: "15-11-2025")
      expect(row).to have_content("Brak")
    end
  end

  describe "Preparations tab — template selector and preview" do
    before do
      visit "/admin/trips/#{trip.id}"
      click_link "Przygotowania"
    end

    it "shows template selector with current template selected" do
      expect(page).to have_select("template-select", selected: "Domyślny szablon (domyślny)")
    end

    it "shows server-rendered preview with trip data" do
      within("#rendered-preview") do
        expect(page).to have_content("Przygotowania na wyjazd")
        expect(page).to have_content("01 / 12 / 2025")
        expect(page).to have_content(admin_user.full_name)
      end
    end

    it "does not show editor elements" do
      expect(page).not_to have_css("#editor-section")
      expect(page).not_to have_css(".element")
      expect(page).not_to have_css(".ProseMirror")
    end

    it "does not show edit button but keeps print" do
      expect(page).not_to have_button("Edytuj")
      expect(page).to have_button("Drukuj przygotowania")
    end

    it "does not show autosave status" do
      expect(page).not_to have_css("#editor-status")
    end

    it "does not show template action buttons" do
      expect(page).not_to have_button("Zaktualizuj szablon")
      expect(page).not_to have_button("Zapisz jako nowy szablon")
      expect(page).not_to have_button("Przywróć szablon")
    end
  end

  describe "Changing template updates preview" do
    before do
      visit "/admin/trips/#{trip.id}"
      click_link "Przygotowania"
    end

    it "updates preview when selecting a different template" do
      select "Inny szablon", from: "template-select"

      within("#rendered-preview") do
        expect(page).to have_content("Inny szablon", wait: 5)
        expect(page).to have_content("01 / 12 / 2025")
      end

      trip.reload
      expect(trip.preparation_template).to eq(other_template)
    end
  end

  describe "Selecting no template" do
    before do
      visit "/admin/trips/#{trip.id}"
      click_link "Przygotowania"
    end

    it "clears preview and unlinks template" do
      select "— brak szablonu —", from: "template-select"

      within("#rendered-preview") do
        expect(page).not_to have_content("Przygotowania na wyjazd", wait: 5)
      end

      trip.reload
      expect(trip.preparation_template_id).to be_nil
    end
  end
end
