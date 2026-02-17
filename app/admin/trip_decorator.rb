class TripDecorator < SimpleDelegator
  SUMMABLE_FIELDS = %i[
    sandwich_count
    provision_count
    soup_count
    chocolate_count
    cat_food_count
    dog_food_count
    package_count
  ].freeze

  def formatted_date
    date.strftime("%d / %m / %Y")
  end

  def decorated_groups
    @decorated_groups ||= groups.map { |g| TripGroupDecorator.new(g) }
  end

  SUMMABLE_FIELDS.each do |field|
    define_method(:"total_#{field}") do
      decorated_groups.sum { |g| g.public_send(field) }
    end
  end
end
