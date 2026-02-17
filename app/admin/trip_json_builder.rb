module TripJsonBuilder
  module_function

  def build(trip)
    decorated = TripDecorator.new(trip)

    groups = decorated.decorated_groups.map do |g|
      {
        name: g.name,
        sandwich_count: g.sandwich_count,
        provision_count: g.provision_count,
        soup_count: g.soup_count,
        water: g.water,
        tea: g.tea,
        books: g.books,
        extras: g.extras,
        chocolate_count: g.chocolate_count,
        has_cat_food: g.has_cat_food,
        has_dog_food: g.has_dog_food,
        cat_food_count: g.cat_food_count,
        dog_food_count: g.dog_food_count,
        has_packages: g.has_packages,
        package_count: g.package_count
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
