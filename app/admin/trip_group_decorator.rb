class TripGroupDecorator < SimpleDelegator
  def name
    [prefix, volunteers].join(": ")
  end

  def water_count
    sparkling_water_count + still_water_count
  end

  def water
    count = water_count
    return "brak" if count.zero?
    "#{count} but#{(count == 1) ? "elka" : "elki"}"
  end

  def tea
    if person_count > AppSetting.instance.persons_per_thermos
      "dwa duże termosy"
    else
      "jeden duży termos"
    end
  end

  def has_cat_food
    cat_food_count > 0
  end

  def has_dog_food
    dog_food_count > 0
  end

  def cat_food_count
    trip_destinations.map { |td|
      td.active_animals.count(&:is_a_cat?)
    }.sum
  end

  def dog_food_count
    trip_destinations.map { |td|
      td.active_animals.count(&:is_a_dog?)
    }.sum
  end

  def sparkling_water_count
    people_across_destinations.sum(&:sparkling_water)
  end

  def still_water_count
    people_across_destinations.sum(&:still_water)
  end

  def long_term_provisions_count
    people_across_destinations.count(&:long_term_provisions)
  end

  def long_term_provisions_recipients
    join_names(people_across_destinations.select(&:long_term_provisions))
  end

  def sparkling_water_recipients
    format_water_recipients(:sparkling_water)
  end

  def still_water_recipients
    format_water_recipients(:still_water)
  end

  def package_recipients
    people_across_destinations
      .select { |p| p.packed_packages.any? }
      .map { |p| "#{p.full_name} (#{p.packed_packages.size})" }
      .join(", ")
  end

  def people_for_json
    people_across_destinations.map do |p|
      {
        name: p.full_name,
        long_term_provisions: p.long_term_provisions,
        sparkling_water_count: p.sparkling_water,
        still_water_count: p.still_water,
        book_preferences: p.book_preferences,
        has_package: p.packed_packages.any?
      }
    end
  end

  private

  def prefix
    "GR #{number}"
  end

  def volunteers
    super.join(", ")
  end

  def people_across_destinations
    @people_across_destinations ||= trip_destinations.flat_map { |td| td.active_people.includes(:packed_packages).to_a }
  end

  def format_water_recipients(count_attr)
    people_across_destinations
      .select { |p| p.public_send(count_attr).to_i > 0 }
      .map { |p| "#{p.full_name} (#{p.public_send(count_attr)})" }
      .join(", ")
  end

  def join_names(people)
    people.map(&:full_name).join(", ")
  end
end
