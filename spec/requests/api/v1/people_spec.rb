require "swagger_helper"

RSpec.describe "People", :requires_auth, type: :request do
  let(:region) { FactoryBot.create(:region) }
  let(:location) { FactoryBot.create(:location, region: region) }
  let(:item_category) { FactoryBot.create(:item_category) }
  let(:person) { FactoryBot.create(:person, location: location, first_name: "Ryszard", code: "012", phone_number: "123456789") }
  let!(:person_size) { FactoryBot.create(:person_size, person: person, item_category: item_category) }
  let!(:item_request) { FactoryBot.create(:item_request, person: person, item_category: item_category) }
  let!(:visit_summary) { FactoryBot.create(:visit_summary, location: location) }
  let!(:package) { FactoryBot.create(:package, :packed, receiver: person) }

  before do
    person.visit_summaries << visit_summary
  end

  path "/api/v1/people" do
    get("list people") do
      tags "People"
      produces "application/json"

      response(200, "successful") do
        before do |example|
          FactoryBot.create(:person, :inactive)
          submit_request(example.metadata)
        end

        it "returns a 200 response" do |example|
          assert_response_matches_metadata(example.metadata)
        end

        it "returns only active people" do
          result = JSON.parse(response.body)
          expect(result.count).to eq Person.active.count
        end

        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {
              examples: {
                example: {
                  value: JSON.parse(response.body, symbolize_names: true)
                }
              }
            }
          }
        end

        run_test!
      end
    end
  end

  path "/api/v1/people/{id}" do
    parameter name: "id", in: :path, type: :string, description: "id"

    get("show person") do
      tags "People"
      response(200, "successful") do
        let(:id) { person.id }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns a 200 response" do |example|
          assert_response_matches_metadata(example.metadata)
        end

        it "returns a person" do
          result = JSON.parse(response.body)
          expect(result["id"]).to eq person.id
          expect(result["name"]).to eq person.first_name
          expect(result["phone_number"]).to eq person.phone_number

          expect(result["sizes"].count).to eq 1
          expect(result["sizes"].first.symbolize_keys)
            .to eq({item_category_id: person_size.item_category_id,
                    item_category_name: person_size.item_category_name,
                    size: person_size.size})

          expect(result["item_requests"].count).to eq 1
          expect(result["item_requests"].first.symbolize_keys)
            .to eq({id: item_request.id,
                    item_category_id: item_request.item_category_id,
                    item_category_name: item_request.item_category_name,
                    item_category_icon_name: item_request.item_category_icon_name,
                    size: item_request.size,
                    comment: item_request.comment,
                    created_at: item_request.created_at.as_json,
                    status: item_request.status})

          expect(result["visit_summaries"].count).to eq 1
          expect(result["visit_summaries"].first.symbolize_keys)
            .to eq({id: visit_summary.id, content: visit_summary.content, visit_date: visit_summary.visit_date.as_json, author: visit_summary.author})

          expect(result["packed_packages"].count).to eq 1
          expect(result["packed_packages"].first.symbolize_keys)
            .to eq({id: package.id})
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

    patch("update person") do
      tags "People"
      consumes "application/json"
      parameter name: :person_data, in: :body, schema: {
        type: :object,
        properties: {
          person: {
            type: :object,
            properties: {
              first_name: {type: :string},
              requests_status: {type: :string, enum: ["green", "yellow", "red"]},
              code: {type: :string},
              location_id: {type: :integer},
              phone_number: {type: :string}
            }
          }
        }
      }

      response(200, "successful") do
        let(:id) { person.id }
        let(:person_data) {
          {person:
           {first_name: "Robert", requests_status: "yellow", phone_number: "234567890"}}
        }

        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        run_test!
      end
    end

    put("update person") do
      tags "People"
      consumes "application/json"
      parameter name: :person_data, in: :body, schema: {
        type: :object,
        properties: {
          person: {
            type: :object,
            properties: {
              first_name: {type: :string},
              requests_status: {type: :string, enum: ["green", "yellow", "red"]},
              code: {type: :string},
              location_id: {type: :integer},
              phone_number: {type: :string}
            }
          }
        }
      }

      response(200, "successful") do
        let(:id) { person.id }
        let(:person_data) {
          {person:
           {first_name: "Robert", requests_status: "yellow", phone_number: "987654321"}}
        }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns a 200 response" do |example|
          assert_response_matches_metadata(example.metadata)
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
