require "swagger_helper"

RSpec.describe "Library People", type: :request do
  let(:location) { FactoryBot.create(:location, name: "Planty 1") }
  let!(:person) { FactoryBot.create(:person, first_name: "Anna", last_name: "Kowalska", code: "777", location: location) }

  path "/api/v1/library/people" do
    get("list people") do
      tags "Library People"
      produces "application/json"
      parameter name: :location_id, in: :query, type: :integer, required: false
      parameter name: :q, in: :query, type: :string, required: false, description: "search by name/code"

      response(200, "successful") do
        let(:location_id) { nil }
        let(:q) { nil }

        before do |example|
          FactoryBot.create(:person, :inactive)
          submit_request(example.metadata)
        end

        it "returns 200" do |example|
          assert_response_matches_metadata(example.metadata)
        end

        it "returns active people with lean payload" do
          result = JSON.parse(response.body)
          expect(result.length).to eq 1
          row = result.first
          expect(row["id"]).to eq person.id
          expect(row["first_name"]).to eq "Anna"
          expect(row["last_name"]).to eq "Kowalska"
          expect(row["code"]).to eq "777"
          expect(row["location_id"]).to eq location.id
          expect(row["book_preferences"]).to be_nil.or be_a(String)
        end

        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {example: JSON.parse(response.body, symbolize_names: true)}
          }
        end
      end

      response(200, "filtered by location_id") do
        let(:location_id) { location.id }
        let(:q) { nil }

        before do |example|
          FactoryBot.create(:person)
          submit_request(example.metadata)
        end

        it "returns people only at that location" do
          result = JSON.parse(response.body)
          expect(result.length).to eq 1
          expect(result.first["location_id"]).to eq location.id
        end
      end

      response(200, "filtered by q") do
        let(:location_id) { nil }
        let(:q) { "777" }

        before do |example|
          FactoryBot.create(:person, first_name: "Other", last_name: "Person")
          submit_request(example.metadata)
        end

        it "matches code or name" do
          result = JSON.parse(response.body)
          expect(result.length).to eq 1
          expect(result.first["code"]).to eq "777"
        end
      end
    end
  end
end
