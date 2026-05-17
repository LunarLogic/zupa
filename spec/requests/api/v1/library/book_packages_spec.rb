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

        it "flips each book's status to packed" do
          expect(book1.reload.status).to eq "packed"
          expect(book2.reload.status).to eq "packed"
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

      response(422, "receiver_id does not exist") do
        let(:book_package_data) { {book_package: {receiver_id: 999_999}} }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns validation errors" do
          result = JSON.parse(response.body)
          expect(result["errors"]).to include("receiver")
        end
      end

      response(422, "one book_id does not exist (atomic rollback)") do
        let(:book1) { FactoryBot.create(:book, title: "Lalka") }
        let(:book_package_data) {
          {book_package: {receiver_id: receiver.id, book_ids: [book1.id, 999_999]}}
        }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns 422 and persists nothing" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(BookPackage.where(note: nil, receiver: receiver).count).to eq 1
          expect(book1.reload.status).to eq "available"
        end
      end

      response(422, "one book is already packed in another package (atomic rollback)") do
        let(:available_book) { FactoryBot.create(:book, title: "Lalka") }
        let(:already_packed) {
          book = FactoryBot.create(:book, title: "Hobbit")
          FactoryBot.create(:book_package_item, book_package: book_package, book: book)
          book
        }
        let(:book_package_data) {
          {book_package: {receiver_id: receiver.id, book_ids: [available_book.id, already_packed.id]}}
        }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns 422 and persists no new package or item" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(BookPackage.where(receiver: receiver).count).to eq 1
          expect(available_book.reload.status).to eq "available"
          expect(already_packed.reload.status).to eq "packed"
          expect(BookPackageItem.where(book: already_packed).pluck(:book_package_id))
            .to contain_exactly(book_package.id)
        end
      end

      response(422, "one book is borrowed (atomic rollback)") do
        let(:borrowed_book) { FactoryBot.create(:book, title: "Pan Tadeusz", status: :borrowed) }
        let(:book_package_data) {
          {book_package: {receiver_id: receiver.id, book_ids: [borrowed_book.id]}}
        }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns 422 and leaves the book borrowed" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(borrowed_book.reload.status).to eq "borrowed"
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

      response(200, "delivering marks child books as borrowed") do
        let(:pkg) { FactoryBot.create(:book_package, :packed, receiver: receiver) }
        let(:packed_book) {
          book = FactoryBot.create(:book, title: "Lalka")
          FactoryBot.create(:book_package_item, book_package: pkg, book: book)
          book
        }
        let(:id) { pkg.id }
        let(:book_package_data) { {book_package: {status: "delivered", delivered_by: "Wanda W."}} }

        before do |example|
          packed_book # force creation
          submit_request(example.metadata)
        end

        it "flips packed child books to borrowed" do
          expect(response).to have_http_status(:ok)
          expect(packed_book.reload.status).to eq "borrowed"
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

        it "flips book status to packed" do
          expect(book.reload.status).to eq "packed"
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

      response(422, "book is packed in a different package") do
        let(:id) { book_package.id }
        let(:other_pkg) { FactoryBot.create(:book_package, receiver: receiver) }
        let(:book) { FactoryBot.create(:book) }
        let!(:foreign_item) { FactoryBot.create(:book_package_item, book_package: other_pkg, book: book) }
        let(:item_data) { {book_id: book.id} }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns 422 and keeps the book in the original package" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(book.reload.status).to eq "packed"
          expect(BookPackageItem.where(book: book).pluck(:book_package_id))
            .to contain_exactly(other_pkg.id)
        end
      end

      response(422, "book is borrowed") do
        let(:id) { book_package.id }
        let(:book) { FactoryBot.create(:book, status: :borrowed) }
        let(:item_data) { {book_id: book.id} }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns 422 and leaves the book borrowed" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(book.reload.status).to eq "borrowed"
        end
      end

      response(422, "book_id does not exist") do
        let(:id) { book_package.id }
        let(:item_data) { {book_id: 999_999} }

        before do |example|
          submit_request(example.metadata)
        end

        it "returns validation errors" do
          result = JSON.parse(response.body)
          expect(result["errors"]).to include("book")
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

        it "flips book status back to available" do
          expect(book.reload.status).to eq "available"
        end
      end

      response(204, "removing item from delivered package keeps book borrowed") do
        let(:delivered_pkg) { FactoryBot.create(:book_package, :delivered, receiver: receiver) }
        let(:id) { delivered_pkg.id }
        let(:book) { FactoryBot.create(:book, status: :borrowed) }
        let!(:item) {
          # Bypass both validations and callbacks: a delivered-package item points
          # at a borrowed book, which mirrors the real lifecycle after
          # status: packing → packed → delivered.
          now = Time.current
          BookPackageItem.insert!({book_package_id: delivered_pkg.id, book_id: book.id, created_at: now, updated_at: now})
          BookPackageItem.find_by!(book_package: delivered_pkg, book: book)
        }
        let(:book_id) { book.id }

        before do |example|
          submit_request(example.metadata)
        end

        it "leaves the book borrowed" do
          expect(response).to have_http_status(:no_content)
          expect(book.reload.status).to eq "borrowed"
        end
      end
    end
  end
end
