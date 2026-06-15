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
      create(:trip_group, trip: t, number: 1, volunteer_names: ["Anna", "Bartek"])
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

  describe "Books tab" do
    let(:trip_with_books) do
      create(:trip, date: "2025-10-10", organiser: admin_user).tap do |t|
        g1 = create(:trip_group, trip: t, number: 1, volunteer_names: ["Anna"])
        g2 = create(:trip_group, trip: t, number: 2, volunteer_names: ["Bartek"])
        loc_a = create(:location, name: "Lokacja A")
        loc_b = create(:location, name: "Lokacja B")
        loc_c = create(:location, name: "Lokacja C")
        create(:person, location: loc_a, first_name: "Czytelnik", last_name: "Pierwszy",
          book_preferences: "Kryminały")
        create(:person, location: loc_b, first_name: "Czytelnik", last_name: "Drugi",
          book_preferences: "Fantastyka")
        create(:person, location: loc_c, first_name: "Niezainteresowany", last_name: "Trzeci",
          book_preferences: nil)
        create(:trip_destination, trip_group: g1, location: loc_a)
        create(:trip_destination, trip_group: g2, location: loc_b)
        create(:trip_destination, trip_group: g2, location: loc_c)
      end
    end

    it "groups entries by trip group with one section per group" do
      visit "/admin/trips/#{trip_with_books.id}"
      click_link "Książki"

      within("#books-content") do
        expect(page).to have_css("h3", text: "GR 1")
        expect(page).to have_css("h3", text: "GR 2")
        expect(page).to have_css("table", count: 2)
      end
    end

    it "shows person names, locations and book preferences" do
      visit "/admin/trips/#{trip_with_books.id}"
      click_link "Książki"

      within("#books-content") do
        expect(page).to have_content("Czytelnik")
        expect(page).not_to have_content("Pierwszy")
        expect(page).not_to have_content("Drugi")
        expect(page).to have_content("Lokacja A")
        expect(page).to have_content("Kryminały")

        expect(page).to have_content("Lokacja B")
        expect(page).to have_content("Fantastyka")
      end
    end

    it "skips people without book preferences" do
      visit "/admin/trips/#{trip_with_books.id}"
      click_link "Książki"

      expect(page).not_to have_content("Niezainteresowany Trzeci")
      expect(page).not_to have_content("Lokacja C")
    end

    it "shows print button when entries exist" do
      visit "/admin/trips/#{trip_with_books.id}"
      click_link "Książki"

      expect(page).to have_button("Drukuj książki")
    end

    it "shows empty message and hides print button when no preferences anywhere" do
      empty_trip = create(:trip, date: "2025-10-11", organiser: admin_user).tap do |t|
        g = create(:trip_group, trip: t, number: 1, volunteer_names: ["Ola"])
        loc = create(:location, name: "Bez książek")
        create(:person, location: loc, book_preferences: nil)
        create(:trip_destination, trip_group: g, location: loc)
      end

      visit "/admin/trips/#{empty_trip.id}"
      click_link "Książki"

      expect(page).to have_content("Żadna osoba nie ma zapisanych preferencji książkowych.")
      expect(page).not_to have_button("Drukuj książki")
    end

    it "shows the riding crew next to each group number" do
      visit "/admin/trips/#{trip_with_books.id}"
      click_link "Książki"

      within("#books-content") do
        expect(page).to have_css("h3", text: "GR 1 — Anna")
        expect(page).to have_css("h3", text: "GR 2 — Bartek")
      end
    end

    it "shows book preferences from group (estimated) locations that have no person cards" do
      group_trip = create(:trip, date: "2025-10-13", organiser: admin_user).tap do |t|
        g = create(:trip_group, trip: t, number: 1, volunteer_names: ["Ola"])
        loc = create(:location, name: "Miejsce grupowe", location_type: "estimated",
          estimated_person_count: 8, book_preferences: "Reportaże i kryminały")
        create(:trip_destination, trip_group: g, location: loc)
      end

      visit "/admin/trips/#{group_trip.id}"
      click_link "Książki"

      within("#books-content") do
        expect(page).to have_css("h3", text: "GR 1 — Ola")
        expect(page).to have_content("Miejsce grupowe")
        expect(page).to have_content("Całe miejsce")
        expect(page).to have_content("Reportaże i kryminały")
      end
    end

    it "omits groups that have no people with preferences" do
      partial_trip = create(:trip, date: "2025-10-12", organiser: admin_user).tap do |t|
        g1 = create(:trip_group, trip: t, number: 1, volunteer_names: ["Kasia"])
        g2 = create(:trip_group, trip: t, number: 2, volunteer_names: ["Marek"])
        loc1 = create(:location, name: "Z książkami")
        loc2 = create(:location, name: "Bez")
        create(:person, location: loc1, first_name: "Czyta", last_name: "Książki",
          book_preferences: "Poezja")
        create(:person, location: loc2, book_preferences: nil)
        create(:trip_destination, trip_group: g1, location: loc1)
        create(:trip_destination, trip_group: g2, location: loc2)
      end

      visit "/admin/trips/#{partial_trip.id}"
      click_link "Książki"

      within("#books-content") do
        expect(page).to have_css("h3", text: "GR 1")
        expect(page).not_to have_css("h3", text: "GR 2")
        expect(page).to have_css("table", count: 1)
      end
    end
  end
end
