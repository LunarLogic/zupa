Trestle.resource(:preparation_templates) do
  menu do
    item :preparation_templates, icon: "fa fa-file-alt", label: "Szablony przygotowań", priority: 22, group: :trips, badge: PreparationTemplate.count
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
        <div class="element" data-template-id="#{template.id || "new"}"></div>
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
        <style>
          #variable-reference .var { font-family: monospace; background: #f0f0f0; padding: 1px 4px; border-radius: 3px; cursor: pointer; }
          #variable-reference .var:hover { background: #e0e0e0; }
          #variable-reference .copy-icon { cursor: pointer; margin-left: 3px; opacity: 0.4; font-size: 0.8em; }
          #variable-reference .copy-icon:hover { opacity: 0.8; }
          #variable-reference .copy-icon.copied { opacity: 0.8; color: #28a745; }
        </style>
        <div style="margin-top: 0.5rem; padding: 0.5rem 1rem;">
          <p><strong>Ogólne:</strong></p>
          <ul>
            <li><span class="var">{{date}}</span> — data wyjazdu</li>
            <li><span class="var">{{organiser}}</span> — organizator</li>
            <li><span class="var">{{group_count}}</span> — liczba grup</li>
          </ul>
          <p><strong>Grupy</strong> (wewnątrz <span class="var">{{#groups}}...{{/groups}}</span>):</p>
          <ul>
            <li><span class="var">{{name}}</span> — nazwa grupy</li>
            <li><span class="var">{{sandwich_count}}</span> — kanapki</li>
            <li><span class="var">{{soup_count}}</span> — zupy</li>
            <li><span class="var">{{water}}</span> — woda (łączna liczba butelek)</li>
            <li><span class="var">{{sparkling_water_count}}</span> / <span class="var">{{still_water_count}}</span> — butelki z podziałem na gazowaną/niegazowaną</li>
            <li><span class="var">{{sparkling_water_recipients}}</span> / <span class="var">{{still_water_recipients}}</span> — dla kogo i ile butelek</li>
            <li><span class="var">{{tea}}</span> — herbata</li>
            <li><span class="var">{{chocolate_count}}</span> — czekolady</li>
            <li><span class="var">{{has_cat_food}}</span> / <span class="var">{{cat_food_count}}</span> — karma dla kotów</li>
            <li><span class="var">{{has_dog_food}}</span> / <span class="var">{{dog_food_count}}</span> — karma dla psów</li>
            <li><span class="var">{{has_packages}}</span> / <span class="var">{{package_count}}</span> — paczki</li>
            <li><span class="var">{{package_recipients}}</span> — dla kogo paczki z Magazynu Ciepła</li>
            <li><span class="var">{{long_term_provisions_count}}</span> / <span class="var">{{long_term_provisions_recipients}}</span> — prowiant długoterminowy (liczba i dla kogo)</li>
            <li><span class="var">{{#people}}{{name}}{{/people}}</span> — iteracja po osobach (pola: <span class="var">name</span>, <span class="var">long_term_provisions</span>, <span class="var">sparkling_water_count</span>, <span class="var">still_water_count</span>, <span class="var">book_preferences</span>, <span class="var">has_package</span>)</li>
          </ul>
          <p style="color: #666; font-size: 0.9em;">Informacja o książkach znajduje się teraz w osobnej zakładce „Książki” na wyjeździe.</p>
          <p><strong>Podsumowanie</strong> (sumy ze wszystkich grup):</p>
          <ul>
            <li><span class="var">{{total_sandwich_count}}</span> — kanapki łącznie</li>
            <li><span class="var">{{total_soup_count}}</span> — zupy łącznie</li>
            <li><span class="var">{{total_chocolate_count}}</span> — czekolady łącznie</li>
            <li><span class="var">{{total_cat_food_count}}</span> — karma dla kotów łącznie</li>
            <li><span class="var">{{total_dog_food_count}}</span> — karma dla psów łącznie</li>
            <li><span class="var">{{total_package_count}}</span> — paczki łącznie</li>
            <li><span class="var">{{total_sparkling_water_count}}</span> / <span class="var">{{total_still_water_count}}</span> — woda łącznie</li>
            <li><span class="var">{{total_long_term_provisions_count}}</span> — prowiant długoterminowy łącznie</li>
          </ul>
        </div>
        <script>
          (function() {
            document.querySelectorAll('#variable-reference .var').forEach(function(el) {
              var icon = document.createElement('span');
              icon.className = 'copy-icon fa fa-clipboard';
              icon.title = 'Kopiuj';
              icon.addEventListener('click', function(e) {
                e.stopPropagation();
                navigator.clipboard.writeText(el.textContent);
                icon.classList.replace('fa-clipboard', 'fa-check');
                icon.classList.add('copied');
                setTimeout(function() {
                  icon.classList.replace('fa-check', 'fa-clipboard');
                  icon.classList.remove('copied');
                }, 1500);
              });
              el.after(icon);
            });
          })();
        </script>
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
