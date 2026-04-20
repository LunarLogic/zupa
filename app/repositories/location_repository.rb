class LocationRepository
  def find_by_name_approximation(name, includes: [])
    matching_locations(name, includes).find do |location|
      remove_whitespace(location.name) == remove_whitespace(name)
    end
  end

  def active_with_recency(before_date: nil)
    last_scheduled = TripDestination
      .joins(trip_group: :trip)
      .where(trips: {status: Trip.statuses[:published]})
      .group(:location_id)
      .maximum("trips.date")

    recent_rank = recent_trip_rank_by_location(before_date)

    Location.where(status: "active").order(:name).map do |loc|
      {
        location: loc,
        last_scheduled_at: last_scheduled[loc.id],
        recent_rank: recent_rank[loc.id]
      }
    end
  end

  private

  def recent_trip_rank_by_location(before_date)
    scope = Trip.where(status: Trip.statuses[:published])
    scope = scope.where("date < ?", before_date) if before_date
    recent_trips = scope.order(date: :desc).limit(2).to_a

    recent_trips.each_with_index.each_with_object({}) do |(trip, idx), acc|
      location_ids = TripDestination
        .joins(:trip_group)
        .where(trip_groups: {trip_id: trip.id})
        .distinct.pluck(:location_id)
      location_ids.each { |lid| acc[lid] ||= idx }
    end
  end

  def matching_locations(name, includes)
    with_includes(includes).where("name LIKE ?", "%#{name_prefix(name)}%")
  end

  def name_prefix(name)
    name.split("-").first.strip
  end

  def remove_whitespace(name)
    name.gsub(/\s+/, "")
  end

  def with_includes(includes)
    Location.includes(includes)
  end
end
