Trestle.resource(:item_requests) do
  collection do
    ItemRequest.includes(:person, :item_category).all
  end

  build_instance do |attrs, params|
    scope = params[:person_id] ? Person.find(params[:person_id]).item_requests : ItemRequest
    scope.new(attrs)
  end

  menu do
    item :item_requests, icon: "fa fa-life-ring", priority: 30, badge: ItemRequest.count, group: :wardrobe
  end

  scopes do
    scope :all, default: true, label: "Wszystkie"
    ItemRequest.statuses.keys.map do |s|
      scope s, label: translate(s)
    end
  end

  table do
    column :status, align: :center, sort: :status do |ir|
      text = I18n.t(ir.status, scope: :item_request_statuses)
      status_tag(text, "ir_#{ir.status}")
    end
    column :person_full_name_with_code, sort: false do |ir|
      link_to(ir.person_full_name_with_code, people_admin_path(ir.person))
    end
    column :item_category, sort: false
    column :size
    column :comment
    column :requested_by
    column :created_at, sort: {default: true, default_order: :desc}
    actions
  end

  form dialog: true do |item_request|
    select :person_id, Person.all
    unless item_request.persisted? && item_request.packing_process_started?
      statuses = ItemRequest.not_packing_statuses.map { |status| [translate(status), status] }
      collection_radio_buttons :status, statuses, :second, :first
    end
    select :item_category_id, ItemCategory.all
    text_area :comment
    text_field :size
    text_field :requested_by
  end
end

private

def translate(status)
  I18n.t(status, scope: :item_request_statuses)
end
