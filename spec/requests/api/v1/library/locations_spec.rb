require "swagger_helper"

RSpec.describe "Library Locations", type: :request do
  let!(:region) { FactoryBot.create(:region, name: "Kraków") }
  let!(:location) { FactoryBot.create(:location, name: "Planty 1", region: region) }

  path "/api/v1/library/locations" do
    get("list locations") do
      tags "Library Locations"
      produces "application/json"
      parameter name: :q, in: :query, type: :string, required: false, description: "search by name"

      response(200, "successful") do
        let(:q) { nil }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns 200" do |example|
          assert_response_matches_metadata(example.metadata)
        end

        it "returns active locations with lean payload" do
          result = JSON.parse(response.body)
          expect(result.length).to be >= 1
          row = result.first
          expect(row["id"]).to eq location.id
          expect(row["name"]).to eq "Planty 1"
          expect(row["region_name"]).to eq "Kraków"
        end

        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {example: JSON.parse(response.body, symbolize_names: true)}
          }
        end
      end

      response(200, "filtered by q") do
        let(:q) { "Plant" }

        before do |example|
          FactoryBot.create(:location, name: "Other Park", region: region)
          submit_request(example.metadata)
        end

        it "returns only matching" do
          result = JSON.parse(response.body)
          expect(result.map { |r| r["name"] }).to all(include("Plant"))
        end
      end
    end
  end
end
