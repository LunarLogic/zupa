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
    # Fetch last trip and default template for preview
    last_trip = Trip.active.order(date: :desc).includes(:groups, :organiser).first
    default_template = PreparationTemplate.default_template.first

    # Prepare trip data for preview
    if last_trip
      groups = last_trip.groups.map do |group|
        g = TripGroupDecorator.new(group)
        {
          name: g.name,
          sandwich_count: g.sandwich_count,
          provision_count: g.provision_count,
          soup_count: g.soup_count,
          water: g.water,
          tea: g.tea,
          books: g.books,
          extras: g.extras,
          chocolate_count: g.chocolate_count,
          has_cat_food: g.has_cat_food,
          has_dog_food: g.has_dog_food,
          cat_food_count: g.cat_food_count,
          dog_food_count: g.dog_food_count,
          has_packages: g.has_packages,
          package_count: g.package_count
        }
      end

      trip_json = {
        date: last_trip.date.strftime("%d / %m / %Y"),
        organiser: last_trip.organiser_name,
        groups: groups
      }.as_json
    else
      trip_json = {
        date: Date.today.strftime("%d / %m / %Y"),
        organiser: "Organizator",
        groups: []
      }.as_json
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
            <li><code>{{provision_count}}</code> — prowianty</li>
            <li><code>{{soup_count}}</code> — zupy</li>
            <li><code>{{water}}</code> — woda</li>
            <li><code>{{tea}}</code> — herbata</li>
            <li><code>{{books}}</code> — książki</li>
            <li><code>{{extras}}</code> — dodatki</li>
            <li><code>{{chocolate_count}}</code> — czekolady</li>
            <li><code>{{has_cat_food}}</code> / <code>{{cat_food_count}}</code> — karma dla kotów</li>
            <li><code>{{has_dog_food}}</code> / <code>{{dog_food_count}}</code> — karma dla psów</li>
            <li><code>{{has_packages}}</code> / <code>{{package_count}}</code> — paczki</li>
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
