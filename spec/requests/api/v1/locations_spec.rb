require "swagger_helper"

RSpec.describe "api/v1/locations", :requires_auth, type: :request do
  let(:region) { FactoryBot.create(:region) }
  let!(:location) { FactoryBot.create(:location, region: region, name: "Active Location") }
  let!(:inactive_location) { FactoryBot.create(:location, region: region, status: :inactive, name: "Inactive Location") }
  let!(:pending_location) { FactoryBot.create(:location, region: region, status: :pending_verification, name: "Pending Location") }
  let!(:person) { FactoryBot.create(:person, location: location, first_name: "Ryszard", code: "012", phone_number: "123456789") }
  let!(:animal) { FactoryBot.create(:animal, active: true, location: location) }
  let!(:summary) { FactoryBot.create(:visit_summary, location: location) }

  path "/api/v1/locations" do
    get("list locations") do
      tags "Locations"
      response(200, "successful") do
        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        it "returns only active locations" do
          result = JSON.parse(response.body)
          names = result.map { |location| location["name"] }

          expect(names).to include("Active Location")
          expect(names).not_to include("Inactive Location")
          expect(names).not_to include("Pending Location")
        end

        run_test!
      end
    end
  end

  path "/api/v1/locations/{id}" do
    parameter name: "id", in: :path, type: :string, description: "id"

    get("show location") do
      tags "Locations"
      response(200, "successful") do
        let(:id) { location.id }

        before do |example|
          FactoryBot.create(:person, :inactive, location: location)
          FactoryBot.create(:animal, active: false, location: location)
          submit_request(example.metadata)
        end

        it "returns a 200 response" do |example|
          assert_response_matches_metadata(example.metadata)
        end

        it "returns a location" do
          result = JSON.parse(response.body)
          expect(result["id"]).to eq location.id
          expect(result["name"]).to eq location.name
          expect(result["people"].count).to eq 1
          expect(result["people"].first.symbolize_keys)
            .to eq({id: person.id,
                    name: person.name,
                    phone_number: person.phone_number,
                    code: person.code,
                    location: {"name" => person.location.name}})
          expect(result["animals"].count).to eq 1
          expect(result["animals"].first.symbolize_keys)
            .to eq({id: animal.id,
                    name: animal.name,
                    species: animal.species})
          expect(result["visit_summaries"].count).to eq 1
          expect(result["visit_summaries"].first.symbolize_keys)
            .to eq({visit_date: summary.visit_date.to_s,
                    content: summary.content,
                    author: summary.author})
        end

        it "returns only active people in location" do
          result = JSON.parse(response.body)
          expect(result["people"].count).to eq 1
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
