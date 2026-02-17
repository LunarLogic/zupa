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
      create(:trip_group, trip: t, number: 1, volunteers: ["Anna", "Bartek"])
      create(:trip_group, trip: t, number: 2, volunteers: ["Celina"])
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
      group_template = create(:preparation_template, :default,
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
end
