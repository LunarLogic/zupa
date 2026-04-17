json.extract! trip, :id, :date, :active, :destination_count, :volunteer_count, :person_count

json.groups do
  json.array! trip.groups, partial: "group", as: :group
end
