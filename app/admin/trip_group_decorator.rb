class TripGroupDecorator < SimpleDelegator
  def name
    [prefix, volunteers].join(": ")
  end

  def water
    count = water_count + 1
    "#{count} zgrzewk#{(count == 1) ? "a" : "i"}"
  end

  def tea
    if water_count >= 4
      "jeden duży termos + jeden mały termos"
    else
      "jeden duży termos"
    end
  end

  def books
    trip_destinations
      .map(&:additional_info)
      .compact
      .flat_map { |info| info.lines }
      .select { |line| line.strip.start_with?("Książki:") }
      .map { |line| line.sub("Książki:", "").strip }
      .reject(&:blank?)
      .join("\n")
  end

  def extras
    # trip_destinations.flat_map(&:extra_notes).uniq
  end

  def chocolate_count
    person_count
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

  private

  def prefix
    "GR #{number}"
  end

  def volunteers
    super.join(", ")
  end
end
