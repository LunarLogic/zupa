require "swagger_helper"

RSpec.describe "api/v1/item_requests", :requires_auth, type: :request do
  let!(:person) { FactoryBot.create(:person) }
  let!(:item_category) { FactoryBot.create(:item_category) }
  let(:item_request) { FactoryBot.create(:item_request, person: person, item_category: item_category) }

  path "/api/v1/people/{person_id}/item_requests" do
    parameter name: "person_id", in: :path, type: :string, description: "person_id"

    post("create item_request") do
      tags "Item Requests"
      consumes "application/json"
      parameter name: :item_request_data, in: :body, schema: {
        type: :object,
        properties: {
          item_request: {
            type: :object,
            properties: {
              size: {type: :string},
              comment: {type: :string},
              item_category_id: {type: :integer}
            }
          }
        }
      }
      response(201, "created") do
        let(:person_id) { person.id }
        let(:item_request_data) {
          {
            item_request:
            {
              size: "XL",
              comment: "Tylko nie czerwone",
              item_category_id: item_category.id
            }
          }
        }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns a 201 response" do |example|
          assert_response_matches_metadata(example.metadata)
        end

        it "creates an item_request" do
          expect(ItemRequest.count).to eq 1
          ir = ItemRequest.last

          expect(ir.person).to eq person
          expect(ir.item_category).to eq item_category
          expect(ir.comment).to eq "Tylko nie czerwone"
          expect(ir.size).to eq "XL"
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

  path "/api/v1/item_requests/{id}" do
    parameter name: "id", in: :path, type: :string, description: "id"
    patch("update item_request") do
      tags "Item Requests"
      consumes "application/json"
      parameter name: :item_request_data, in: :body, schema: {
        type: :object,
        properties: {
          item_request: {
            type: :object,
            properties: {
              size: {type: :string},
              comment: {type: :string},
              item_category_id: {type: :integer}
            }
          }
        }
      }

      response(200, "successful") do
        let(:id) { item_request.id }
        let(:item_request_data) {
          {
            item_request:
            {
              size: "S",
              comment: "Na rzepy"
            }
          }
        }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns a 200 response" do |example|
          assert_response_matches_metadata(example.metadata)
        end

        it "updates an item_request" do
          ir = ItemRequest.last

          expect(ir.comment).to eq "Na rzepy"
          expect(ir.size).to eq "S"
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

    put("update item_request") do
      tags "Item Requests"
      consumes "application/json"
      parameter name: :item_request_data, in: :body, schema: {
        type: :object,
        properties: {
          item_request: {
            type: :object,
            properties: {
              size: {type: :string},
              comment: {type: :string},
              item_category_id: {type: :integer}
            }
          }
        }
      }

      response(200, "successful") do
        let(:id) { item_request.id }
        let(:item_request_data) {
          {
            item_request:
            {
              size: "S",
              comment: "Na rzepy"
            }
          }
        }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns a 200 response" do |example|
          assert_response_matches_metadata(example.metadata)
        end

        it "updates an item_request" do
          ir = ItemRequest.last

          expect(ir.comment).to eq "Na rzepy"
          expect(ir.size).to eq "S"
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
