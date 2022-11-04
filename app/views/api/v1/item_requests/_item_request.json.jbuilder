json.extract! item_request, :id, :size, :comment, :person_id, :item_category_id, :prepared_at, :delivered_at, :delivery_confirmed_at, :status, :created_at, :updated_at
json.url api_v1_item_request_url(item_request, format: :json)
