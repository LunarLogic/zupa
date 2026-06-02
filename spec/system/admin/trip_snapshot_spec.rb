require "rails_helper"

RSpec.describe "Admin trip snapshot", type: :system do
  let(:admin_user) { create(:admin_user, password: "password123", password_confirmation: "password123") }

  let(:location) { create(:location, name: "Lokacja A") }
  let!(:person) do
    create(:person, location: location, active: true,
      first_name: "Helena", last_name: "Kowalska",
      chocolates: 4, soups: 2, sandwiches: 5,
      book_preferences: "Reportaż")
  end

  let(:trip) do
    t = create(:trip, date: "2025-09-10", organiser: admin_user)
    g = create(:trip_group, trip: t, number: 1, volunteers: ["Anna"])
    create(:trip_destination, trip_group: g, location: location)
    t
  end

  before do
    trip
    admin_login(admin_user)
  end

  describe "Książki tab reads from snapshot" do
    it "keeps showing the snapshotted person even after they are deleted from the location" do
      visit "/admin/trips/#{trip.id}"
      click_link "Książki"

      within("#books-content") do
        expect(page).to have_content("Helena")
        expect(page).not_to have_content("Kowalska")
        expect(page).to have_content("Reportaż")
      end

      person.destroy

      visit "/admin/trips/#{trip.id}"
      click_link "Książki"

      within("#books-content") do
        expect(page).to have_content("Helena")
        expect(page).not_to have_content("Kowalska")
        expect(page).to have_content("Reportaż")
      end
    end

    it "ignores live changes to the person's book_preferences" do
      person.update!(book_preferences: "ZMIANA")

      visit "/admin/trips/#{trip.id}"
      click_link "Książki"

      within("#books-content") do
        expect(page).to have_content("Reportaż")
        expect(page).not_to have_content("ZMIANA")
      end
    end
  end

  describe "preparations preview reads from snapshot totals" do
    let(:template) do
      create(:preparation_template, :default,
        name: "Test",
        content_html: "<p>SAND={{total_sandwich_count}}</p><p>SOUP={{total_soup_count}}</p><p>CHOC={{total_chocolate_count}}</p>")
    end

    before do
      trip.update!(preparation_template: template)
      person.update!(sandwiches: 999, soups: 999, chocolates: 999)
    end

    it "shows totals frozen at trip creation, not live Person values" do
      visit "/admin/trips/#{trip.id}"
      click_link "Przygotowania"

      within("#rendered-preview") do
        expect(page).to have_content("SAND=5")
        expect(page).to have_content("SOUP=2")
        expect(page).to have_content("CHOC=4")
      end
    end
  end
end
