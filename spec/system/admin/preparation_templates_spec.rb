require "rails_helper"

RSpec.describe "Admin preparation templates", type: :system do
  let(:admin_user) { create(:admin_user, password: "password123", password_confirmation: "password123") }

  let(:default_template) do
    create(:preparation_template, :default,
      name: "Domyślny szablon",
      content_html: "<h1>Przygotowania na wyjazd</h1><p>Data: {{date}}</p><p>Organizator: {{organiser}}</p>")
  end

  let(:trip) do
    create(:trip, date: "2025-12-01", organiser: admin_user).tap do |t|
      create(:trip_group, trip: t, number: 1, volunteer_names: ["Anna", "Bartek"])
      create(:trip_group, trip: t, number: 2, volunteer_names: ["Celina"])
    end
  end

  before do
    default_template
    trip
    admin_login(admin_user)
  end

  describe "Creating a new template" do
    before do
      visit "/admin/preparation_templates/new"
    end

    it "shows a single-tab form without tab navigation" do
      expect(page).not_to have_css(".nav-tabs")
      expect(page).not_to have_css('[role="tablist"]')
    end

    it "has name input and default checkbox" do
      expect(page).to have_field("Nazwa")
      expect(page).to have_css("input[type='checkbox'][name='preparation_template[default]']", visible: :all)
      expect(page).to have_content("Domyślny")
    end

    it "shows preview pre-filled with default template content rendered with last trip data" do
      within("#rendered-preview") do
        expect(page).to have_content("Przygotowania na wyjazd")
        expect(page).to have_content("01 / 12 / 2025")
      end
    end

    it 'has "Edytuj" button below the preview' do
      expect(page).to have_button("Edytuj")
    end

    it 'hides "Zapisz" and "Anuluj" buttons before edit mode is activated' do
      expect(page).not_to have_css("#editor-section button[type='submit']", visible: true)
      expect(page).not_to have_css("#editor-section button", text: "Anuluj", visible: true)
    end

    it 'shows "Zapisz" and "Anuluj" buttons after clicking Edytuj' do
      click_button "Edytuj"
      expect(page).to have_css(".ProseMirror", wait: 5)

      expect(page).to have_css("#editor-section button[type='submit']", text: "Zapisz")
      expect(page).to have_css("#editor-section button", text: "Anuluj")
    end

    it "does not trigger autosave" do
      fill_in "Nazwa", with: "Test szablon"
      expect(page).not_to have_css("#editor-status")
    end
  end

  describe "Editing content via TipTap builder" do
    before do
      visit "/admin/preparation_templates/new"
    end

    it "shows TipTap editor when clicking Edytuj" do
      click_button "Edytuj"

      expect(page).to have_css(".ProseMirror", wait: 5)
    end

    it "shows table toolbar in editor" do
      click_button "Edytuj"

      expect(page).to have_css(".table-toolbar", wait: 5)
      expect(page).to have_button("Wstaw Tabelę")
    end

    it "updates preview live as content changes" do
      click_button "Edytuj"

      editor = find(".ProseMirror", wait: 5)
      editor.set("<p>Nowa treść</p>")

      within("#rendered-preview") do
        expect(page).to have_content("Nowa treść", wait: 5)
      end
    end
  end

  describe "Saving a new template" do
    before do
      visit "/admin/preparation_templates/new"
    end

    it "persists the template and shows success flash" do
      fill_in "Nazwa", with: "Mój nowy szablon"
      click_button "Edytuj"
      expect(page).to have_css(".ProseMirror", wait: 5)

      click_button "Zapisz"

      expect(page).to have_content("pomyślnie utworzony", wait: 5)
      expect(page).to have_field("Nazwa", with: "Mój nowy szablon")

      template = PreparationTemplate.find_by(name: "Mój nowy szablon")
      expect(template).to be_present
      expect(template.content_html).to be_present
    end

    it "stays on the template edit page after save with preview visible" do
      fill_in "Nazwa", with: "Zostaje na edycji"
      click_button "Edytuj"
      expect(page).to have_css(".ProseMirror", wait: 5)
      click_button "Zapisz"

      expect(page).to have_field("Nazwa", with: "Zostaje na edycji")
      expect(page).to have_current_path(%r{/admin/preparation_templates/\d+})

      within("#rendered-preview") do
        expect(page).to have_content("01 / 12 / 2025")
      end
    end
  end

  describe "Cancelling template editing" do
    it "closes the editor and stays on the same page" do
      visit "/admin/preparation_templates/new"
      click_button "Edytuj"
      expect(page).to have_css(".ProseMirror", wait: 5)

      click_button "Anuluj"

      expect(page).not_to have_css("#editor-section", visible: true)
      expect(page).not_to have_css("#editor-section button[type='submit']", visible: true)
      expect(page).to have_button("Edytuj")
      expect(page).to have_css("#rendered-preview")
    end

    it "reverts content changes in the preview" do
      visit "/admin/preparation_templates/new"

      within("#rendered-preview") do
        expect(page).to have_content("Przygotowania na wyjazd")
      end

      click_button "Edytuj"
      editor = find(".ProseMirror", wait: 5)
      editor.set("<p>Zmieniona treść</p>")

      within("#rendered-preview") do
        expect(page).to have_content("Zmieniona treść", wait: 5)
      end

      click_button "Anuluj"

      within("#rendered-preview") do
        expect(page).to have_content("Przygotowania na wyjazd")
        expect(page).not_to have_content("Zmieniona treść")
      end
    end
  end

  describe "Variable reference" do
    before do
      visit "/admin/preparation_templates/new"
    end

    it "shows variable reference only after entering edit mode" do
      expect(page).not_to have_css("details#variable-reference", visible: true)

      click_button "Edytuj"
      expect(page).to have_css("details#variable-reference", visible: true)

      find("details#variable-reference summary").click

      within("details#variable-reference") do
        expect(page).to have_content("{{date}}")
        expect(page).to have_content("{{organiser}}")
        expect(page).to have_content("{{#groups}}...{{/groups}}")
        expect(page).to have_content("{{name}}")
        expect(page).to have_content("{{sandwich_count}}")
        expect(page).to have_content("{{total_sandwich_count}}")
        expect(page).to have_content("{{total_long_term_provisions_count}}")
        expect(page).to have_content("{{total_soup_count}}")
        expect(page).to have_content("{{total_chocolate_count}}")
        expect(page).to have_content("{{total_cat_food_count}}")
        expect(page).to have_content("{{total_dog_food_count}}")
        expect(page).to have_content("{{total_package_count}}")
      end
    end
  end

  describe "Editing an existing template" do
    let!(:existing_template) do
      create(:preparation_template,
        name: "Istniejący szablon",
        content_html: "<p>Stara treść: {{date}}</p>")
    end

    before do
      visit "/admin/preparation_templates/#{existing_template.id}"
    end

    it "shows pre-filled name and preview with rendered content" do
      expect(page).to have_field("Nazwa", with: "Istniejący szablon")

      within("#rendered-preview") do
        expect(page).to have_content("Stara treść")
        expect(page).to have_content("01 / 12 / 2025")
      end
    end

    it "allows editing content and saving changes with preview visible after save" do
      click_button "Edytuj"
      expect(page).to have_css(".ProseMirror", wait: 5)

      click_button "Zapisz"

      expect(page).to have_css(".alert-success, .flash-message-success, .alert-info", wait: 5)
      expect(page).to have_current_path(%r{/admin/preparation_templates/#{existing_template.id}})

      within("#rendered-preview") do
        expect(page).to have_content("Stara treść")
        expect(page).to have_content("01 / 12 / 2025")
      end
    end
  end

  describe "Preview renders with last trip data" do
    it "displays trip group data in the preview" do
      create(:preparation_template, :default,
        name: "Szablon z grupami",
        content_html: <<~HTML)
          <h1>Przygotowania</h1>
          <p>Data: {{date}}</p>
          <p>Organizator: {{organiser}}</p>
          {{#groups}}
          <p>Grupa: {{name}}</p>
          {{/groups}}
        HTML

      visit "/admin/preparation_templates/new"

      within("#rendered-preview") do
        expect(page).to have_content("01 / 12 / 2025")
        expect(page).to have_content(admin_user.full_name)
      end
    end
  end

  describe "Preview renders totals across groups" do
    let(:trip_with_data) do
      create(:trip, date: "2025-12-15", organiser: admin_user).tap do |t|
        g1 = create(:trip_group, trip: t, number: 1, volunteer_names: ["Anna"])
        g2 = create(:trip_group, trip: t, number: 2, volunteer_names: ["Bartek"])
        loc_a = create(:location, name: "Lokacja A")
        loc_b = create(:location, name: "Lokacja B")
        p_a = create(:person, location: loc_a, long_term_provisions: true)
        p_b1 = create(:person, location: loc_b, long_term_provisions: true)
        p_b2 = create(:person, location: loc_b, long_term_provisions: true)
        td1 = create(:trip_destination, trip_group: g1, location: loc_a, sandwiches: 3, soups: 2)
        td2 = create(:trip_destination, trip_group: g2, location: loc_b, sandwiches: 5, soups: 4)
        TripDestinationPerson.create!(trip_destination: td1, person: p_a,
          first_name: p_a.first_name, last_name: p_a.last_name, long_term_provisions: true)
        TripDestinationPerson.create!(trip_destination: td2, person: p_b1,
          first_name: p_b1.first_name, last_name: p_b1.last_name, long_term_provisions: true)
        TripDestinationPerson.create!(trip_destination: td2, person: p_b2,
          first_name: p_b2.first_name, last_name: p_b2.last_name, long_term_provisions: true)
      end
    end

    let(:totals_template) do
      create(:preparation_template,
        name: "Szablon z sumami",
        content_html: <<~HTML)
          <p>Kanapki: {{total_sandwich_count}}</p>
          <p>Zupy: {{total_soup_count}}</p>
          <p>Prowianty: {{total_long_term_provisions_count}}</p>
        HTML
    end

    before do
      trip_with_data
      totals_template
    end

    it "renders summed totals from all groups in the preview" do
      visit "/admin/preparation_templates/#{totals_template.id}"

      within("#rendered-preview") do
        expect(page).to have_content("Kanapki: 8")
        expect(page).to have_content("Zupy: 6")
        expect(page).to have_content("Prowianty: 3")
      end
    end
  end
end
