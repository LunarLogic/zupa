class LocationRepository
  def find_by_name_approximation(name, includes: [])
    matching_locations(name, includes).find do |location|
      remove_whitespace(location.name) == remove_whitespace(name)
    end
  end

  # Active locations (alphabetical) annotated with how recently each was
  # visited, for the manual trip builder. recent_rank: 0 = on the most recent
  # trip, 1 = the one before, nil = neither. Powers the "visited recently"
  # badges that replace the map's recency colouring.
  def active_with_recency(before_date: nil)
    last_scheduled = TripDestination
      .joins(trip_group: :trip)
      .group(:location_id)
      .maximum("trips.date")
    rank = recent_trip_rank_by_location(before_date)

    Location.where(status: "active").order(:name).map do |location|
      {
        location: location,
        last_scheduled_at: last_scheduled[location.id],
        recent_rank: rank[location.id]
      }
    end
  end

  private

  def recent_trip_rank_by_location(before_date)
    scope = Trip.all
    scope = scope.where("date < ?", before_date) if before_date
    recent_trips = scope.order(date: :desc).limit(2).to_a

    recent_trips.each_with_index.each_with_object({}) do |(trip, index), ranks|
      TripDestination
        .joins(:trip_group)
        .where(trip_groups: {trip_id: trip.id})
        .distinct
        .pluck(:location_id)
        .each { |location_id| ranks[location_id] ||= index }
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
