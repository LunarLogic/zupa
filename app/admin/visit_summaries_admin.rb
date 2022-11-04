Trestle.resource(:visit_summaries) do
  collection do
    VisitSummary.includes(:location, people_visit_summaries: :person).order(created_at: :desc).all
  end

  menu do
    item :visit_summaries, icon: "fa fa-pen-nib", priority: 40, badge: VisitSummary.count, group: :trips
  end

  table do
    column :id
    column :author
    column :location
    column :content do |visit_summary|
      truncate(visit_summary.content, length: 50)
    end
    column :visit_date, sort: {default: true, default_order: :desc}
    actions
  end

  form do |visit_summary|
    tab :data do
      text_field :author
      select :location_id, Location.all
      text_area :content
      date_field :visit_date
    end

    tab :people, badge: visit_summary.people_visit_summaries.size do
      table visit_summary.people_visit_summaries, admin: :people_visit_summaries do
        column :person
        column :visit_summary do |pvs|
          pvs.visit_summary.content
        end
        column :author do |pvs|
          pvs.visit_summary.author
        end
        column :date do |pvs|
          pvs.visit_summary.visit_date
        end
        actions
      end
    end
  end

  controller do
    def create
      @visit_summary = ::BuildVisitSummary.new(admin.permitted_params(params)).call

      if admin.save_instance(@visit_summary, action: :create)
        flash[:message] = "Visit summary successfully created."
        redirect_to admin.path(:show, id: @visit_summary.id)
      else
        flash.now[:error] = "Failed to create visit summary."
        render :new, status: :unprocessable_entity
      end
    end
  end
end
