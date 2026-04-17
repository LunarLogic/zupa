module TripJsonBuilder
  module_function

  def build(trip)
    decorated = TripDecorator.new(trip)

    groups = decorated.decorated_groups.map do |g|
      {
        name: g.name,
        sandwich_count: g.sandwich_count,
        soup_count: g.soup_count,
        water: g.water,
        tea: g.tea,
        chocolate_count: g.chocolate_count,
        has_cat_food: g.has_cat_food,
        has_dog_food: g.has_dog_food,
        cat_food_count: g.cat_food_count,
        dog_food_count: g.dog_food_count,
        has_packages: g.has_packages,
        package_count: g.package_count,
        sparkling_water_count: g.sparkling_water_count,
        still_water_count: g.still_water_count,
        long_term_provisions_count: g.long_term_provisions_count,
        long_term_provisions_recipients: g.long_term_provisions_recipients,
        sparkling_water_recipients: g.sparkling_water_recipients,
        still_water_recipients: g.still_water_recipients,
        package_recipients: g.package_recipients,
        people: g.people_for_json
      }
    end

    totals = TripDecorator::SUMMABLE_FIELDS.each_with_object({}) do |field, hash|
      hash[:"total_#{field}"] = decorated.public_send(:"total_#{field}")
    end

    {
      date: decorated.formatted_date,
      organiser: decorated.organiser_name,
      groups: groups,
      **totals
    }.as_json
  end

  def default_json
    {
      date: Date.today.strftime("%d / %m / %Y"),
      organiser: "Organizator",
      groups: []
    }.as_json
  end
end
