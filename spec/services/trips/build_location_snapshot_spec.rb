require "rails_helper"

describe Trips::BuildLocationSnapshot do
  it "returns location json" do
    people = [
      build(:person, id: 1),
      build(:person, id: 2)
    ]
    animals = [
      build(:animal, id: 1),
      build(:animal, id: 2)
    ]
    location = build(
      :location,
      id: 1,
      name: "Pustostan nad rzeką",
      region_id: 1,
      longitude: 1.2,
      latitude: 3.5,
      info: "about location",
      active_people: people,
      active_animals: animals
    )

    expect(described_class.new.call(location:)).to eq({
      id: 1,
      name: "Pustostan nad rzeką",
      region_id: 1,
      longitude: BigDecimal("1.2"),
      latitude: BigDecimal("3.5"),
      info: "about location",
      active_people_ids: [1, 2],
      active_animals_ids: [1, 2]
    })
  end
end
