require "swagger_helper"

RSpec.describe "Library ISBN Lookup", type: :request do
  path "/api/v1/library/isbn_lookup" do
    get("lookup book metadata by ISBN") do
      tags "Library Books"
      produces "application/json"
      parameter name: :isbn, in: :query, type: :string, required: true,
        description: "ISBN-10 or ISBN-13 (hyphens and spaces stripped server-side)"

      response(200, "found via BN (Polish National Library)") do
        # Sapkowski — Krew elfów (Wiedźmin 3). Stable in BN's catalogue.
        let(:isbn) { "9788375780659" }

        before do |example|
          VCR.use_cassette("bn/krew_elfow") { submit_request(example.metadata) }
        end

        it "returns normalized book metadata sourced from BN" do
          result = JSON.parse(response.body)
          expect(result["isbn"]).to eq isbn
          expect(result["title"]).to be_present
          expect(result["author"]).to be_present
          expect(result.keys).to include("title", "author", "length", "publisher", "pub_year", "cover_url")
        end

        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {example: JSON.parse(response.body, symbolize_names: true)}
          }
        end
      end

      response(200, "found via OpenLibrary fallback when BN misses") do
        # The Count of Monte Cristo — not in BN's Polish catalogue; OpenLibrary covers it.
        let(:isbn) { "9780140449266" }

        before do |example|
          VCR.use_cassette("isbn_chain/bn_miss_ol_hit") { submit_request(example.metadata) }
        end

        it "returns normalized book metadata sourced from OpenLibrary" do
          result = JSON.parse(response.body)
          expect(result["isbn"]).to eq isbn
          expect(result["title"]).to be_a(String).and(be_present)
        end
      end

      response(404, "not found in any source") do
        # Plausibly-formatted ISBN that neither BN nor OpenLibrary has.
        let(:isbn) { "9788373271005" }

        before do |example|
          VCR.use_cassette("isbn_chain/all_miss") { submit_request(example.metadata) }
        end

        it "returns 404 when no source has the record" do |example|
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
