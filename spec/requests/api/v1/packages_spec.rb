require "swagger_helper"

RSpec.describe "api/v1/packages", :requires_auth, type: :request do
  let(:person) { FactoryBot.create(:person) }
  let(:package) { FactoryBot.create(:package, :packed, receiver: person) }
  let!(:item_request) { create(:item_request, person: person, status: :prepared, package: package) }

  path "/api/v1/packages/{id}" do
    parameter name: "id", in: :path, type: :string, description: "id"
    patch("update package") do
      tags "Packages"
      consumes "application/json"
      parameter name: :package_data, in: :body, schema: {
        type: :object,
        properties: {
          package: {
            type: :object,
            properties: {
              status: {type: :string}
            }
          }
        }
      }

      response(200, "successful") do
        let(:id) { package.id }
        let(:package_data) {
          {
            package:
            {
              status: :delivered
            }
          }
        }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns a 200 response" do |example|
          assert_response_matches_metadata(example.metadata)
        end

        it "updates a package" do
          package = Package.last

          expect(package.status).to eq "delivered"
          expect(package.delivered_at).to be_within(1.second).of(Time.zone.now)
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

    put("update package") do
      tags "Packages"
      consumes "application/json"
      parameter name: :package_data, in: :body, schema: {
        type: :object,
        properties: {
          package: {
            type: :object,
            properties: {
              status: {type: :string}
            }
          }
        }
      }

      response(200, "successful") do
        let(:id) { package.id }
        let(:package_data) {
          {
            package:
            {
              status: :delivered
            }
          }
        }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns a 200 response" do |example|
          assert_response_matches_metadata(example.metadata)
        end

        it "updates a package" do
          package = Package.last

          expect(package.status).to eq "delivered"
          expect(package.delivered_at).to be_within(1.second).of(Time.zone.now)
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
