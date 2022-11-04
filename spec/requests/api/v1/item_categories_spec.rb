require "swagger_helper"

RSpec.describe "api/v1/item_categories", :requires_auth, type: :request do
  let!(:item_category) { FactoryBot.create(:item_category) }

  path "/api/v1/item_categories" do
    get("list item_categories") do
      tags "Item Categories"
      response(200, "successful") do
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
  end
end
