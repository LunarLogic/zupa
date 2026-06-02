require "swagger_helper"

RSpec.describe "Trips", :requires_auth, type: :request do
  let!(:trip) { FactoryBot.create(:trip) }
  let!(:trip_group) { FactoryBot.create(:trip_group, trip: trip) }
  let!(:location) { FactoryBot.create(:location, name: "Second Location") }
  let!(:person) {
    FactoryBot.create(:person, location: location,
      sandwiches: 10, soups: 1, chocolates: 1,
      sparkling_water: 3, still_water: 1,
      long_term_provisions: true, book_preferences: "Kryminały")
  }
  let!(:animal) { FactoryBot.create(:animal, active: true, location: location) }
  let!(:package) { FactoryBot.create(:package, :packed, receiver: person) }
  let!(:trip_destination) {
    FactoryBot.create(:trip_destination, trip_group: trip_group, location: location, additional_info: "text", order: 2)
  }

  path "/api/v1/trips/{id}" do
    parameter name: "id", in: :path, type: :string, description: "id"
    get("show trip") do
      tags "Trips"
      response(200, "successful") do
        let(:id) { trip.id }

        before do |example|
          first_location = FactoryBot.create(:location, name: "First Location")
          FactoryBot.create(:trip_destination, trip_group: trip_group, location: first_location, order: 1)
          FactoryBot.create(:person, :inactive, location: location)

          submit_request(example.metadata)
        end

        it "returns a 200 response" do |example|
          assert_response_matches_metadata(example.metadata)
        end

        it "returns a trip" do
          result = JSON.parse(response.body)
          expect(result).to be_an(Array)
          expect(result.size).to eq(1)

          first_trip = result.first
          expect(first_trip["id"]).to eq trip.id
          expect(first_trip["active"]).to eq trip.active
          expect(first_trip["date"]).to eq trip.date.strftime("%Y-%m-%d")
          expect(first_trip["destination_count"]).to eq trip.destination_count
          expect(first_trip["volunteer_count"]).to eq trip.volunteer_count
          expect(first_trip["person_count"]).to eq trip.person_count
          expect(first_trip["groups"].first["id"]).to eq trip_group.id
          expect(first_trip["groups"].first["number"]).to eq trip_group.number
          expect(first_trip["groups"].first["volunteers"]).to eq trip_group.volunteers
          expect(first_trip["groups"].first["person_count"]).to eq trip_group.person_count
          expect(first_trip["groups"].first["destination_count"]).to eq trip_group.destination_count
          expect(first_trip["groups"].first["animal_count"]).to eq 1
          expect(first_trip["groups"].first["chocolate_count"]).to eq trip_group.chocolate_count

          location_json = first_trip["groups"].first["destinations"].second
          destination = TripDestination.where(trip_group: trip_group, location: location).first
          expect(location_json["location_id"]).to eq destination.location_id
          expect(location_json["name"]).to eq destination.name
          expect(location_json["latitude"]).to eq destination.latitude.to_s
          expect(location_json["longitude"]).to eq destination.longitude.to_s
          expect(location_json["longitude"]).to eq destination.longitude.to_s
          expect(location_json["has_people"]).to be_truthy
          expect(location_json["person_count"]).to eq 1
          expect(location_json["soup_count"]).to eq 1
          expect(location_json["sandwich_count"]).to eq 10
          expect(location_json["provision_count"]).to eq 1
          expect(location_json["book_count"]).to eq 1
          expect(location_json["water_count"]).to eq 4
          expect(location_json["package_count"]).to eq 1
          expect(location_json["animal_count"]).to eq 1
          expect(location_json["chocolate_count"]).to eq 1
          expect(location_json["additional_info"]).to eq "text"
          expect(location_json["has_sandwiches"]).to be_truthy
          expect(location_json["has_soups"]).to be_truthy
          expect(location_json["has_provisions"]).to be_truthy
          expect(location_json["has_books"]).to be_truthy
          expect(location_json["has_waters"]).to be_truthy
          expect(location_json["has_packages"]).to be_truthy
          expect(location_json["has_animals"]).to be_truthy
          expect(location_json["has_chocolates"]).to be_truthy
          expect(location_json["active_animals"].first["species"]).to eq("cat")
          expect(location_json["people"].count).to eq(1)
          expect(location_json["people"].first["first_name"]).to eq person.first_name
          expect(location_json["people"].first["book_preferences"]).to eq "Kryminały"
          expect(location_json["people"].first["sparkling_water"]).to eq 3
          expect(location_json["people"].first["still_water"]).to eq 1
        end

        it "returns destinations in order" do
          trip = JSON.parse(response.body).first
          ordered_names = trip["groups"].first["destinations"].map do |destination|
            destination["name"]
          end

          expect(ordered_names).to eq ["First Location", "Second Location"]
        end

        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
      end
    end
  end

  path "/api/v1/trips/current" do
    get("show current trip") do
      tags "Trips"
      response(200, "successful") do
        before do |example|
          submit_request(example.metadata)
        end

        it "returns a 200 response" do |example|
          assert_response_matches_metadata(example.metadata)
        end

        it "returns a trip" do
          result = JSON.parse(response.body)
          expect(result).to be_an(Array)
          expect(result.size).to eq(1)

          first_trip = result.first
          expect(first_trip["id"]).to eq trip.id
          expect(first_trip["active"]).to eq trip.active
          expect(first_trip["date"]).to eq trip.date.strftime("%Y-%m-%d")
          expect(first_trip["destination_count"]).to eq trip.destination_count
          expect(first_trip["volunteer_count"]).to eq trip.volunteer_count
          expect(first_trip["person_count"]).to eq trip.person_count
          expect(first_trip["groups"].first["id"]).to eq trip_group.id
          expect(first_trip["groups"].first["number"]).to eq trip_group.number
          expect(first_trip["groups"].first["volunteers"]).to eq trip_group.volunteers
          expect(first_trip["groups"].first["person_count"]).to eq trip_group.person_count
          expect(first_trip["groups"].first["destination_count"]).to eq trip_group.destination_count

          location_json = first_trip["groups"].first["destinations"].first
          destination = TripDestination.where(trip_group: trip_group).first
          expect(location_json["location_id"]).to eq destination.location_id
          expect(location_json["name"]).to eq destination.name
          expect(location_json["latitude"]).to eq destination.latitude.to_s
          expect(location_json["longitude"]).to eq destination.longitude.to_s
          expect(location_json["longitude"]).to eq destination.longitude.to_s
          expect(location_json["person_count"]).to eq 1
          expect(location_json["soup_count"]).to eq 1
          expect(location_json["provision_count"]).to eq 1
          expect(location_json["book_count"]).to eq 1
          expect(location_json["water_count"]).to eq 4
          expect(location_json["package_count"]).to eq 1
          expect(location_json["additional_info"]).to eq "text"
          expect(location_json["has_soups"]).to be_truthy
          expect(location_json["has_provisions"]).to be_truthy
          expect(location_json["has_books"]).to be_truthy
          expect(location_json["has_waters"]).to be_truthy
          expect(location_json["has_packages"]).to be_truthy
        end

        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
      end
    end
  end

  path "/api/v1/trips/active" do
    get("show active trips") do
      tags "Trips"
      response(200, "successful") do
        before do |example|
          create_list(:trip, 1, :active)
          submit_request(example.metadata)
        end

        it "returns a 200 response" do |example|
          assert_response_matches_metadata(example.metadata)
        end

        it "returns trips" do
          result = JSON.parse(response.body)
          data = result["data"]
          expect(data).to be_an(Array)
          expect(data.size).to eq(2)
        end

        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
      end
    end
  end

  path "/api/v1/trips/historical" do
    get("show historical trips") do
      tags "Trips"
      parameter name: "page",
        in: :query,
        type: :integer,
        description: "page number",
        required: false
      response(200, "successful") do
        before do |example|
          create_list(:trip, 2, :historical)
          submit_request(example.metadata)
        end

        it "returns a 200 response" do |example|
          assert_response_matches_metadata(example.metadata)
        end

        it "returns trips" do
          result = JSON.parse(response.body)
          data = result["data"]
          expect(data).to be_an(Array)
          expect(data.size).to eq(1)
        end

        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
      end
    end
  end
end
