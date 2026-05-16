require "swagger_helper"

RSpec.describe "Library ISBN Lookup", type: :request do
  path "/api/v1/library/isbn_lookup" do
    get("lookup book metadata by ISBN") do
      tags "Library Books"
      produces "application/json"
      parameter name: :isbn, in: :query, type: :string, required: true,
        description: "ISBN-10 or ISBN-13 (hyphens and spaces stripped server-side)"

      response(200, "found") do
        # The Count of Monte Cristo (Penguin) — stable ISBN with good metadata
        let(:isbn) { "9780140449266" }

        before do |example|
          VCR.use_cassette("openlibrary/monte_cristo") { submit_request(example.metadata) }
        end

        it "returns normalized book metadata" do
          result = JSON.parse(response.body)
          expect(result["isbn"]).to eq isbn
          expect(result["title"]).to be_a(String).and(be_present)
          expect(result.keys).to include("title", "author", "length", "publisher", "pub_year", "cover_url")
        end

        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {example: JSON.parse(response.body, symbolize_names: true)}
          }
        end
      end

      response(404, "not found") do
        # OpenLibrary returns an empty payload `{}` for this ISBN
        let(:isbn) { "9788373271005" }

        before do |example|
          VCR.use_cassette("openlibrary/unknown_isbn") { submit_request(example.metadata) }
        end

        it "returns 404 when OpenLibrary has no record" do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end

      response(422, "missing isbn") do
        let(:isbn) { "" }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns 422" do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end

      response(422, "invalid isbn format") do
        let(:isbn) { "abc" }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns 422 without hitting upstream" do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end
    end
  end
end
