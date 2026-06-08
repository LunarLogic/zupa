require "rails_helper"

RSpec.describe "Admin volunteers", type: :system do
  let(:admin_user) { create(:admin_user, password: "password123", password_confirmation: "password123") }

  before { admin_login(admin_user) }

  it "creates a volunteer" do
    visit "/admin/volunteers/new"
    fill_in "Imię", with: "Jan"
    fill_in "Nazwisko", with: "Nowak"
    click_button "Zapisz", exact: false

    expect(page).to have_content("Sukces")
    expect(Volunteer.exists?(first_name: "Jan", last_name: "Nowak")).to be true

    visit "/admin/volunteers"
    expect(page).to have_content("Nowak")
  end

  it "lists volunteers ordered by last name" do
    create(:volunteer, first_name: "Ada", last_name: "Zielinska")
    create(:volunteer, first_name: "Bob", last_name: "Adamski")

    visit "/admin/volunteers"

    expect(page).to have_content("Adamski")
    expect(page).to have_content("Zielinska")
  end
end
