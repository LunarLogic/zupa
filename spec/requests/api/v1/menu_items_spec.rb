require "swagger_helper"

RSpec.describe "api/v1/menu_items", :requires_auth, type: :request do
  let!(:menu_item) { FactoryBot.create(:menu_item) }

  path "/api/v1/menu_items" do
    get("list menu_items") do
      tags "Menu Items"
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
