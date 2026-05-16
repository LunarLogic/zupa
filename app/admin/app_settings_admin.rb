Trestle.resource(:app_settings, singular: true) do
  menu do
    item :app_settings, icon: "fa fa-cog", label: I18n.t("admin.app_settings.label"), priority: 99, group: :configuration
  end

  instance do
    AppSetting.instance
  end

  remove_action :new, :edit, :destroy

  form do |_setting|
    number_field :persons_per_thermos, min: 1
    number_field :soups_per_person, min: 0
    number_field :chocolates_per_person, min: 0
    number_field :sandwiches_per_person, min: 0
    number_field :sparkling_water_per_person, min: 0
    number_field :still_water_per_person, min: 0
  end

  params do |params|
    params.require(:app_setting).permit(
      :persons_per_thermos,
      :soups_per_person,
      :chocolates_per_person,
      :sandwiches_per_person,
      :sparkling_water_per_person,
      :still_water_per_person
    )
  end
end
