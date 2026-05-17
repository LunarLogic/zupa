require "swagger_helper"

RSpec.describe "Library Book Packages", type: :request do
  let(:location) { FactoryBot.create(:location, name: "Planty 1") }
  let(:receiver) { FactoryBot.create(:person, first_name: "Anna", last_name: "Kowalska", location: location) }
  let!(:book_package) { FactoryBot.create(:book_package, receiver: receiver) }

  path "/api/v1/library/book_packages" do
    get("list book packages") do
      tags "Library Book Packages"
      produces "application/json"
      parameter name: :status, in: :query, type: :string, required: false, description: "filter by status"

      response(200, "successful") do
        let(:status) { nil }

        before do |example|
          FactoryBot.create(:book_package, :delivered, receiver: receiver)
          submit_request(example.metadata)
        end

        it "returns 200" do |example|
          assert_response_matches_metadata(example.metadata)
        end

        it "returns all packages" do
          result = JSON.parse(response.body)
          expect(result.length).to eq 2
          expect(result.first["status"]).to be_a(String)
          expect(result.first["receiver"]["id"]).to eq receiver.id
          expect(result.first["location"]["id"]).to eq location.id
          expect(result.first["receiver"]["location_id"]).to eq location.id
        end

        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {example: JSON.parse(response.body, symbolize_names: true)}
          }
        end
      end

      response(200, "filtered by status") do
        let(:status) { "delivered" }

        before do |example|
          FactoryBot.create(:book_package, :delivered, receiver: receiver)
          submit_request(example.metadata)
        end

        it "returns only matching status" do
          result = JSON.parse(response.body)
          expect(result.length).to eq 1
          expect(result.first["status"]).to eq "delivered"
        end
      end
    end

    post("create book package") do
      tags "Library Book Packages"
      consumes "application/json"
      produces "application/json"
      parameter name: :book_package_data, in: :body, schema: {
        type: :object,
        properties: {
          book_package: {
            type: :object,
            properties: {
              receiver_id: {type: :integer},
              note: {type: :string},
              book_ids: {type: :array, items: {type: :integer}}
            },
            required: %w[receiver_id]
          }
        }
      }

      response(201, "created") do
        let(:book1) { FactoryBot.create(:book, title: "Lalka") }
        let(:book2) { FactoryBot.create(:book, title: "Hobbit") }
        let(:book_package_data) {
          {book_package: {receiver_id: receiver.id, note: "OWK lubi kryminały", book_ids: [book1.id, book2.id]}}
        }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns the new package with items" do
          result = JSON.parse(response.body)
          expect(result["status"]).to eq "packing"
          expect(result["note"]).to eq "OWK lubi kryminały"
          expect(result["books"].map { |b| b["id"] }).to match_array([book1.id, book2.id])
        end
      end

      response(422, "invalid") do
        let(:book_package_data) { {book_package: {receiver_id: nil}} }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns validation errors" do
          result = JSON.parse(response.body)
          expect(result["errors"]).to include("receiver")
        end
      end
    end
  end

  path "/api/v1/library/book_packages/{id}" do
    parameter name: :id, in: :path, type: :string

    get("show book package") do
      tags "Library Book Packages"
      produces "application/json"

      response(200, "successful") do
        let(:id) { book_package.id }
        let!(:book) { FactoryBot.create(:book, title: "Lalka") }
        let!(:item) { FactoryBot.create(:book_package_item, book_package: book_package, book: book) }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns the package with books and receiver/location" do
          result = JSON.parse(response.body)
          expect(result["id"]).to eq book_package.id
          expect(result["receiver"]["first_name"]).to eq "Anna"
          expect(result["location"]["name"]).to eq "Planty 1"
          expect(result["books"].first["title"]).to eq "Lalka"
        end
      end

      response(404, "not found") do
        let(:id) { 999_999 }

        it "returns 404" do
          get("/api/v1/library/book_packages/#{id}")
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    patch("update book package") do
      tags "Library Book Packages"
      consumes "application/json"
      parameter name: :book_package_data, in: :body, schema: {
        type: :object,
        properties: {
          book_package: {
            type: :object,
            properties: {
              status: {type: :string},
              note: {type: :string},
              delivered_by: {type: :string}
            }
          }
        }
      }

      response(200, "status flipped to packed") do
        let(:id) { book_package.id }
        let(:book_package_data) { {book_package: {status: "packed"}} }

        before do |example|
          submit_request(example.metadata)
        end

        it "stamps packed_at" do
          result = JSON.parse(response.body)
          expect(result["status"]).to eq "packed"
          expect(result["packed_at"]).to be_a(String)
        end
      end

      response(200, "status flipped to delivered") do
        let(:id) { FactoryBot.create(:book_package, :packed, receiver: receiver).id }
        let(:book_package_data) { {book_package: {status: "delivered", delivered_by: "Wanda W."}} }

        before do |example|
          submit_request(example.metadata)
        end

        it "stamps delivered_at and stores delivered_by" do
          result = JSON.parse(response.body)
          expect(result["status"]).to eq "delivered"
          expect(result["delivered_at"]).to be_a(String)
          expect(result["delivered_by"]).to eq "Wanda W."
        end
      end

      response(422, "missing delivered_by when delivered") do
        let(:id) { FactoryBot.create(:book_package, :packed, receiver: receiver).id }
        let(:book_package_data) { {book_package: {status: "delivered"}} }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns validation errors" do
          result = JSON.parse(response.body)
          expect(result["errors"]).to include("delivered_by")
        end
      end
    end

    delete("delete book package") do
      tags "Library Book Packages"

      response(204, "deleted") do
        let(:id) { book_package.id }

        before do |example|
          submit_request(example.metadata)
        end

        it "removes the package" do
          expect(BookPackage.exists?(book_package.id)).to be false
        end
      end
    end
  end

  path "/api/v1/library/book_packages/{id}/items" do
    parameter name: :id, in: :path, type: :string

    post("add a book to the package") do
      tags "Library Book Packages"
      consumes "application/json"
      parameter name: :item_data, in: :body, schema: {
        type: :object,
        properties: {book_id: {type: :integer}},
        required: %w[book_id]
      }

      response(201, "added") do
        let(:id) { book_package.id }
        let(:book) { FactoryBot.create(:book, title: "Hobbit") }
        let(:item_data) { {book_id: book.id} }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns the package with the new book" do
          result = JSON.parse(response.body)
          expect(result["books"].map { |b| b["id"] }).to include book.id
        end
      end

      response(422, "duplicate book") do
        let(:id) { book_package.id }
        let(:book) { FactoryBot.create(:book) }
        let!(:existing) { FactoryBot.create(:book_package_item, book_package: book_package, book: book) }
        let(:item_data) { {book_id: book.id} }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns 422" do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end
    end
  end

  path "/api/v1/library/book_packages/{id}/items/{book_id}" do
    parameter name: :id, in: :path, type: :string
    parameter name: :book_id, in: :path, type: :string

    delete("remove a book from the package") do
      tags "Library Book Packages"

      response(204, "removed") do
        let(:id) { book_package.id }
        let(:book) { FactoryBot.create(:book) }
        let!(:item) { FactoryBot.create(:book_package_item, book_package: book_package, book: book) }
        let(:book_id) { book.id }

        before do |example|
          submit_request(example.metadata)
        end

        it "removes the item" do
          expect(book_package.reload.books).not_to include(book)
        end
      end
    end
  end
end
