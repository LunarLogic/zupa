Trestle.resource(:preparation_templates) do
  menu do
    item :preparation_templates, icon: "fa fa-file-alt", label: "Szablony przygotowań", priority: 21, group: :trips
  end

  collection do
    PreparationTemplate.all.order(updated_at: :desc)
  end

  routes do
    patch :update_content, on: :member
  end

  table do
    column :name
    column :default, align: :center do |template|
      if template.default?
        status_tag(icon("fa fa-check"), :success)
      end
    end
    column :trips_count, header: "Wyjazdy" do |template|
      template.trips.count
    end
    column :updated_at
    actions
  end

  form do |template|
    tab :szablon do
      text_field :name
      check_box :default
    end

    tab :edytor do
      if template.new_record?
        text_area :content_html, rows: 10
      else
        render inline: <<~HTML
          <div class="element"
               data-template-id="#{template.id}"
               data-save-url="/admin/preparation_templates/#{template.id}/update_content"></div>
          <div id="editor-status" class="autosave-status">Saved: #{template.updated_at&.strftime("%F %T") || "-"}</div>
          <input type="hidden" name="preparation_template[content_html]" value="#{ERB::Util.html_escape(template.content_html)}" />
        HTML
      end
    end
  end

  controller do
    def update_content
      template = PreparationTemplate.find(params[:id])
      template.update(content_html: params[:preparation_template][:content_html])

      head :ok
    end
  end
end
