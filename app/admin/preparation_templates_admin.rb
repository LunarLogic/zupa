Trestle.resource(:preparation_templates) do
  menu do
    item :preparation_templates, icon: "fa fa-file-alt", label: "Szablony przygotowań", priority: 21, group: :trips
  end

  collection do
    PreparationTemplate.all.order(updated_at: :desc)
  end


  table do
    column :name
    column :default, align: :center do |template|
      if template.default?
        status_tag(icon("fa fa-check"), :success)
      end
    end
    actions
  end

  form do |template|
    # Fetch last trip and default template for preview.
    # Prefer active trips; fall back to any most-recent trip so preview still renders
    # meaningful data in dev/staging where no trip is active.
    last_trip = Trip.active.order(date: :desc).includes(:groups, :organiser).first ||
      Trip.order(date: :desc).includes(:groups, :organiser).first
    default_template = PreparationTemplate.default_template.first

    # Prepare trip data for preview
    trip_json = if last_trip
      TripJsonBuilder.build(last_trip)
    else
      TripJsonBuilder.default_json
    end

    # Determine content for preview
    content_for_preview = if template.new_record?
      default_template&.content_html || "<p>#{I18n.t("admin.preparation_templates.labels.no_default_template")}</p>"
    else
      template.content_html
    end

    # Basic fields
    text_field :name, label: I18n.t("admin.preparation_templates.columns.name")
    check_box :default, label: I18n.t("admin.preparation_templates.columns.default")

    # Hidden field for content (always present for form submission)
    render inline: <<~HTML
      <input type="hidden" name="preparation_template[content_html]" value="#{ERB::Util.html_escape(content_for_preview)}" />
    HTML

    # Editor section (hidden by default), with Zapisz/Anuluj below the editor
    render inline: <<~HTML
      <div id="editor-section" style="display: none;">
        <p><strong>#{I18n.t("admin.preparation_templates.labels.editor")}:</strong></p>
        <div class="element" data-template-id="#{template.id || 'new'}"></div>
        <div style="margin-top: 1rem;">
          <button type="submit" class="btn btn-success">#{I18n.t("admin.preparation_templates.labels.save_button")}</button>
          <button type="button" class="btn btn-default" onclick="window.closeTemplateEditor && window.closeTemplateEditor();">#{I18n.t("admin.preparation_templates.labels.cancel")}</button>
        </div>
      </div>
    HTML

    # Edit button + variable reference (both above preview, reference only visible in edit mode)
    render inline: <<~HTML
      <div style="margin-top: 2rem;">
        <button type="button" id="btn-edit-template" class="btn btn-primary"
                onclick="event.preventDefault(); document.getElementById('editor-section').style.display = 'block'; document.getElementById('variable-reference').style.display = 'block'; this.style.display = 'none'; window.initializeTemplateEditor && window.initializeTemplateEditor();">
          #{I18n.t("admin.preparation_templates.labels.edit_button")}
        </button>
      </div>

      <details id="variable-reference" style="margin-top: 1rem; display: none;">
        <summary><strong>#{I18n.t("admin.preparation_templates.labels.variable_reference")}</strong></summary>
        <style>#variable-reference code { color: black; }</style>
        <div style="margin-top: 0.5rem; padding: 0.5rem 1rem;">
          <p><strong>Ogólne:</strong></p>
          <ul>
            <li><code>{{date}}</code> — data wyjazdu</li>
            <li><code>{{organiser}}</code> — organizator</li>
          </ul>
          <p><strong>Grupy</strong> (wewnątrz <code>{{#groups}}...{{/groups}}</code>):</p>
          <ul>
            <li><code>{{name}}</code> — nazwa grupy</li>
            <li><code>{{sandwich_count}}</code> — kanapki</li>

            <li><code>{{soup_count}}</code> — zupy</li>
            <li><code>{{water}}</code> — woda (łączna liczba butelek)</li>
            <li><code>{{sparkling_water_count}}</code> / <code>{{still_water_count}}</code> — butelki z podziałem na gazowaną/niegazowaną</li>
            <li><code>{{sparkling_water_recipients}}</code> / <code>{{still_water_recipients}}</code> — dla kogo i ile butelek</li>
            <li><code>{{tea}}</code> — herbata</li>
            <li><code>{{extras}}</code> — dodatki</li>
            <li><code>{{chocolate_count}}</code> — czekolady</li>
            <li><code>{{has_cat_food}}</code> / <code>{{cat_food_count}}</code> — karma dla kotów</li>
            <li><code>{{has_dog_food}}</code> / <code>{{dog_food_count}}</code> — karma dla psów</li>
            <li><code>{{has_packages}}</code> / <code>{{package_count}}</code> — paczki</li>
            <li><code>{{package_recipients}}</code> — dla kogo paczki z Magazynu Ciepła</li>
            <li><code>{{long_term_provisions_count}}</code> / <code>{{long_term_provisions_recipients}}</code> — prowiant długoterminowy (liczba i dla kogo)</li>
            <li><code>{{#people}}{{name}}{{/people}}</code> — iteracja po osobach (pola: <code>name</code>, <code>long_term_provisions</code>, <code>sparkling_water_count</code>, <code>still_water_count</code>, <code>book_preferences</code>, <code>has_package</code>)</li>
          </ul>
          <p style="color: #666; font-size: 0.9em;">Informacja o książkach znajduje się teraz w osobnej zakładce „Książki” na wyjeździe.</p>
          <p><strong>Podsumowanie</strong> (sumy ze wszystkich grup):</p>
          <ul>
            <li><code>{{total_sandwich_count}}</code> — kanapki łącznie</li>

            <li><code>{{total_soup_count}}</code> — zupy łącznie</li>
            <li><code>{{total_chocolate_count}}</code> — czekolady łącznie</li>
            <li><code>{{total_cat_food_count}}</code> — karma dla kotów łącznie</li>
            <li><code>{{total_dog_food_count}}</code> — karma dla psów łącznie</li>
            <li><code>{{total_package_count}}</code> — paczki łącznie</li>
            <li><code>{{total_sparkling_water_count}}</code> / <code>{{total_still_water_count}}</code> — woda łącznie</li>
            <li><code>{{total_long_term_provisions_count}}</code> — prowiant długoterminowy łącznie</li>
          </ul>
        </div>
      </details>
    HTML

    # Render preview server-side with Mustache
    rendered_preview = begin
      Mustache.render(content_for_preview, trip_json)
    rescue => e
      "<pre style='color:red;'>#{ERB::Util.html_escape(e.message)}</pre>"
    end

    # Preview section
    render inline: <<~HTML
      <div style="margin-top: 2rem;">
        <p><strong>#{I18n.t("admin.preparation_templates.labels.preview")}:</strong></p>
        <div id="rendered-preview" style="margin-top: 1rem; border: 1px solid #ccc; padding: 1rem; max-height: 400px; overflow: auto;">#{rendered_preview}</div>
        <script id="trip-json" type="application/json">#{trip_json.to_json.html_safe}</script>
      </div>
    HTML
  end

end
