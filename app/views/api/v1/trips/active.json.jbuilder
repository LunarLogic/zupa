json.data do
  json.array! @trips, partial: "api/v1/trips/trip", as: :trip
end
