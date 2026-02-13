# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin login", type: :system do
  let(:admin_user) { create(:admin_user, password: "password123", password_confirmation: "password123") }

  it "logs in with valid credentials" do
    admin_login(admin_user)

    expect(page).not_to have_current_path("/admin/login")
  end

  it "rejects invalid credentials" do
    visit "/admin/login"
    fill_in "Email", with: admin_user.email
    fill_in "Hasło", with: "wrong"
    click_button "Zaloguj się"

    expect(page).to have_current_path("/admin/login")
    expect(page).to have_content("Nieprawidłowe dane logowania")
  end
end
