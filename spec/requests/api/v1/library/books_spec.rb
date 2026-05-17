require "swagger_helper"

RSpec.describe "Library Books", type: :request do
  let!(:book) { FactoryBot.create(:book, title: "Lalka", author: "Bolesław Prus", genres: ["literatura_piekna"]) }

  path "/api/v1/library/books" do
    get("list books") do
      tags "Library Books"
      produces "application/json"
      parameter name: :q, in: :query, type: :string, required: false, description: "search by title/author (ILIKE)"
      parameter name: :status, in: :query, type: :string, required: false, description: "filter by status"
      parameter name: :genre, in: :query, type: :string, required: false, description: "filter by genre (single)"

      response(200, "successful") do
        let(:q) { nil }
        let(:status) { nil }
        let(:genre) { nil }

        before do |example|
          FactoryBot.create(:book, :archived, title: "Old Tome", author: "Ancient")
          FactoryBot.create(:book, title: "Hobbit", author: "Tolkien", genres: ["fantasy"])
          submit_request(example.metadata)
        end

        it "returns 200" do |example|
          assert_response_matches_metadata(example.metadata)
        end

        it "returns all books" do
          result = JSON.parse(response.body)
          expect(result.length).to eq 3
          expect(result.first["title"]).to be_a(String)
          expect(result.first["genres"]).to be_an(Array)
        end

        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {example: JSON.parse(response.body, symbolize_names: true)}
          }
        end
      end

      response(200, "filtered by q") do
        let(:q) { "lalk" }
        let(:status) { nil }
        let(:genre) { nil }

        before do |example|
          FactoryBot.create(:book, title: "Hobbit", author: "Tolkien")
          submit_request(example.metadata)
        end

        it "returns only matching titles" do
          result = JSON.parse(response.body)
          expect(result.length).to eq 1
          expect(result.first["title"]).to eq "Lalka"
        end
      end

      response(200, "filtered by status") do
        let(:q) { nil }
        let(:status) { "archived" }
        let(:genre) { nil }

        before do |example|
          FactoryBot.create(:book, :archived, title: "Old Tome", author: "Ancient")
          submit_request(example.metadata)
        end

        it "returns only archived" do
          result = JSON.parse(response.body)
          expect(result.length).to eq 1
          expect(result.first["status"]).to eq "archived"
        end
      end

      response(200, "filtered by genre") do
        let(:q) { nil }
        let(:status) { nil }
        let(:genre) { "fantasy" }

        before do |example|
          FactoryBot.create(:book, title: "Hobbit", author: "Tolkien", genres: ["fantasy"])
          submit_request(example.metadata)
        end

        it "returns only books tagged with that genre" do
          result = JSON.parse(response.body)
          expect(result.length).to eq 1
          expect(result.first["genres"]).to include "fantasy"
        end
      end
    end

    post("create book") do
      tags "Library Books"
      consumes "application/json"
      produces "application/json"
      parameter name: :book_data, in: :body, schema: {
        type: :object,
        properties: {
          book: {
            type: :object,
            properties: {
              title: {type: :string},
              author: {type: :string},
              isbn: {type: :string},
              description: {type: :string},
              length: {type: :integer},
              publisher: {type: :string},
              pub_year: {type: :integer},
              extra_note: {type: :string},
              status: {type: :string},
              genres: {type: :array, items: {type: :string}}
            },
            required: %w[title author]
          }
        }
      }

      response(201, "created") do
        let(:book_data) { {book: {title: "Pan Tadeusz", author: "Mickiewicz", genres: ["poezja"]}} }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns the new book" do
          result = JSON.parse(response.body)
          expect(result["title"]).to eq "Pan Tadeusz"
          expect(result["author"]).to eq "Mickiewicz"
          expect(result["genres"]).to eq ["poezja"]
          expect(result["status"]).to eq "available"
        end
      end

      response(422, "invalid") do
        let(:book_data) { {book: {title: ""}} }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns validation errors" do
          result = JSON.parse(response.body)
          expect(result["errors"]).to include("title", "author")
        end
      end
    end
  end

  path "/api/v1/library/books/{id}" do
    parameter name: :id, in: :path, type: :string

    get("show book") do
      tags "Library Books"
      produces "application/json"

      response(200, "successful") do
        let(:id) { book.id }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns the book" do
          result = JSON.parse(response.body)
          expect(result["id"]).to eq book.id
          expect(result["title"]).to eq "Lalka"
          expect(result["author"]).to eq "Bolesław Prus"
        end
      end

      response(404, "not found") do
        let(:id) { 999_999 }

        it "returns 404" do
          get("/api/v1/library/books/#{id}")
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    patch("update book") do
      tags "Library Books"
      consumes "application/json"
      parameter name: :book_data, in: :body, schema: {
        type: :object,
        properties: {
          book: {
            type: :object,
            properties: {
              title: {type: :string},
              extra_note: {type: :string},
              genres: {type: :array, items: {type: :string}}
            }
          }
        }
      }

      response(200, "updated") do
        let(:id) { book.id }
        let(:book_data) { {book: {extra_note: "Damaged spine", genres: ["literatura_piekna", "biografia"]}} }

        before do |example|
          submit_request(example.metadata)
        end

        it "updates fields" do
          result = JSON.parse(response.body)
          expect(result["extra_note"]).to eq "Damaged spine"
          expect(result["genres"]).to match_array(["literatura_piekna", "biografia"])
        end
      end
    end

    delete("delete book") do
      tags "Library Books"

      response(204, "deleted") do
        let(:id) { book.id }

        before do |example|
          submit_request(example.metadata)
        end

        it "removes the book" do
          expect(Book.exists?(book.id)).to be false
        end
      end
    end
  end

  path "/api/v1/library/books/{id}/qr_code" do
    parameter name: :id, in: :path, type: :string

    post("bind QR code to book") do
      tags "Library Books"
      consumes "application/json"
      parameter name: :qr_data, in: :body, schema: {
        type: :object,
        properties: {qr_code: {type: :string}},
        required: %w[qr_code]
      }

      response(200, "bound") do
        let(:id) { book.id }
        let(:qr_data) { {qr_code: "QR-NEW-12345"} }

        before do |example|
          submit_request(example.metadata)
        end

        it "binds the QR code" do
          result = JSON.parse(response.body)
          expect(result["qr_code"]).to eq "QR-NEW-12345"
        end
      end

      response(409, "conflict — QR already bound to another book") do
        let(:id) { book.id }
        let!(:other) { FactoryBot.create(:book, :with_qr, qr_code: "QR-TAKEN") }
        let(:qr_data) { {qr_code: "QR-TAKEN"} }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns 409" do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end

      response(422, "missing qr_code") do
        let(:id) { book.id }
        let(:qr_data) { {qr_code: ""} }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns 422" do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end
    end
  end

  path "/api/v1/library/books/{id}/photo" do
    parameter name: :id, in: :path, type: :string

    post("attach cover photo") do
      tags "Library Books"
      consumes "multipart/form-data"
      parameter name: :photo, in: :formData, type: :file, required: true

      response(200, "attached") do
        let(:id) { book.id }
        let(:photo) { fixture_file_upload(Rails.root.join("spec/fixtures/files/sample_cover.png"), "image/png") }

        it "attaches the photo and returns the book with cover_photo_url" do
          # Use request directly because rswag's submit_request doesn't handle multipart well
          post "/api/v1/library/books/#{book.id}/photo", params: {photo: photo}
          expect(response).to have_http_status(:ok)
          result = JSON.parse(response.body)
          expect(result["cover_photo_url"]).to be_a(String)
        end
      end

      response(422, "missing photo") do
        let(:id) { book.id }
        let(:photo) { nil }

        it "returns 422" do
          post "/api/v1/library/books/#{book.id}/photo"
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  path "/api/v1/library/books/by_qr_code" do
    get("look up book by QR code") do
      tags "Library Books"
      produces "application/json"
      parameter name: :qr, in: :query, type: :string, required: true,
        description: "exact QR sticker code bound to a book"

      response(200, "found") do
        let!(:bound) { FactoryBot.create(:book, :with_qr, qr_code: "QR-LOOKUP-1") }
        let(:qr) { "QR-LOOKUP-1" }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns the bound book" do
          result = JSON.parse(response.body)
          expect(result["id"]).to eq bound.id
          expect(result["qr_code"]).to eq "QR-LOOKUP-1"
        end

        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {example: JSON.parse(response.body, symbolize_names: true)}
          }
        end
      end

      response(404, "not found") do
        let(:qr) { "QR-UNKNOWN" }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns 404" do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end

      response(404, "blank qr") do
        let(:qr) { "" }

        before do |example|
          submit_request(example.metadata)
        end

        it "treats blank qr as not found" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
