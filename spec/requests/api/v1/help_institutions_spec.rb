require "swagger_helper"

RSpec.describe "api/v1/help_institutions", :requires_auth, type: :request do
  let!(:help_institution) { FactoryBot.create(:help_institution) }

  path "/api/v1/help_institutions" do
    get("list Help Institutions") do
      tags "Help Institutions"
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
