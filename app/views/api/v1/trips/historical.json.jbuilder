json.pagination do
  json.extract! @pagination, :prev_url, :next_url, :count, :page, :next
end

json.links do
  json.prev @pagination[:prev_url]
  json.next @pagination[:next_url]
end

json.data do
  json.array! @trips, partial: "api/v1/trips/trip", as: :trip
end
