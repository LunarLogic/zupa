Trestle.resource(:volunteers) do
  menu do
    item :volunteers, icon: "fa fa-user-friends", group: :trips, priority: 25
  end

  collection do
    Volunteer.order(:last_name, :first_name)
  end

  table do
    column :last_name
    column :first_name
    column :gender do |volunteer|
      I18n.t("genders.#{volunteer.gender}", default: "") if volunteer.gender
    end
    column :active
    actions
  end

  form do |_volunteer|
    text_field :first_name
    text_field :last_name
    select :gender, [["Kobieta", "female"], ["Mężczyzna", "male"]], include_blank: true
    check_box :active
  end

  controller do
    def destroy
      volunteer = Volunteer.find(params[:id])
      if volunteer.trip_groups.any? || volunteer.driving_groups.any?
        flash[:error] = I18n.t("admin.volunteers.errors.cannot_delete_assigned")
      else
        volunteer.destroy
        flash[:message] = flash_message("destroy.success", title: "", message: "")
      end
      redirect_to admin.path(:index)
    end
  end
end
