class LocationRepository
  def find_by_name_approximation(name, includes: [])
    matching_locations(name, includes).find do |location|
      remove_whitespace(location.name) == remove_whitespace(name)
    end
  end

  private

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
