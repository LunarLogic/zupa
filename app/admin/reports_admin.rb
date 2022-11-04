Trestle.admin(:reports) do
  menu do
    item :reports, icon: "fa fa-file-export", priority: 55, group: :wardrobe
  end

  controller do
    def index
      render "admin_area/reports/index"
    end
  end
end
