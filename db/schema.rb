# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2026_05_30_120006) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "book_package_status_type", ["packing", "packed", "delivered"]
  create_enum "book_status_type", ["available", "packed", "borrowed", "archived"]
  create_enum "item_request_status_type", ["to_prepare", "prepared", "delivered", "rejected", "during_consultation", "packing"]
  create_enum "location_status_type", ["active", "pending_verification", "inactive"]
  create_enum "location_type", ["regular", "estimated"]
  create_enum "menu_item_type", ["internal", "external"]
  create_enum "package_status_type", ["packing", "packed", "delivered"]
  create_enum "request_status_type", ["red", "yellow", "green"]
  create_enum "species_type", ["cat", "dog", "rat", "bird", "other"]

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "first_name"
    t.string "last_name"
    t.string "remember_token"
    t.datetime "remember_token_expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "animals", force: :cascade do |t|
    t.string "name"
    t.boolean "active", default: true
    t.bigint "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "species", default: "cat", null: false, enum_type: "species_type"
    t.index ["location_id"], name: "index_animals_on_location_id"
  end

  create_table "app_settings", force: :cascade do |t|
    t.integer "persons_per_thermos", default: 7, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "chocolates_per_person", default: 1, null: false
    t.integer "sandwiches_per_person", default: 2, null: false
    t.integer "soups_per_person", default: 1, null: false
    t.integer "sparkling_water_per_person", default: 0, null: false
    t.integer "still_water_per_person", default: 0, null: false
  end

  create_table "auth_codes", force: :cascade do |t|
    t.string "value", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "book_package_items", force: :cascade do |t|
    t.bigint "book_package_id", null: false
    t.bigint "book_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_book_package_items_on_book_id"
    t.index ["book_package_id", "book_id"], name: "index_book_package_items_on_package_and_book", unique: true
    t.index ["book_package_id"], name: "index_book_package_items_on_book_package_id"
  end

  create_table "book_packages", force: :cascade do |t|
    t.bigint "receiver_id", null: false
    t.enum "status", default: "packing", null: false, enum_type: "book_package_status_type"
    t.text "note"
    t.datetime "packed_at"
    t.datetime "delivered_at"
    t.string "delivered_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["receiver_id"], name: "index_book_packages_on_receiver_id"
    t.index ["status"], name: "index_book_packages_on_status"
  end

  create_table "books", force: :cascade do |t|
    t.string "title", null: false
    t.string "author", null: false
    t.string "isbn"
    t.text "description"
    t.integer "length"
    t.string "publisher"
    t.integer "pub_year"
    t.string "qr_code"
    t.text "extra_note"
    t.string "genres", default: [], null: false, array: true
    t.enum "status", default: "available", null: false, enum_type: "book_status_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["genres"], name: "index_books_on_genres", using: :gin
    t.index ["isbn"], name: "index_books_on_isbn"
    t.index ["qr_code"], name: "index_books_on_qr_code", unique: true
  end

  create_table "flipper_features", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", force: :cascade do |t|
    t.string "feature_key", null: false
    t.string "key", null: false
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
  end

  create_table "help_institutions", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.text "conditions"
    t.text "timings"
    t.text "items_offered"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "item_categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "available_sizes", default: [], array: true
    t.string "icon_name"
  end

  create_table "item_requests", force: :cascade do |t|
    t.string "size"
    t.text "comment"
    t.bigint "person_id", null: false
    t.bigint "item_category_id", null: false
    t.datetime "prepared_at"
    t.datetime "delivered_at"
    t.datetime "delivery_confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "status", null: false, enum_type: "item_request_status_type"
    t.string "requested_by"
    t.bigint "package_id"
    t.index ["item_category_id"], name: "index_item_requests_on_item_category_id"
    t.index ["package_id"], name: "index_item_requests_on_package_id"
    t.index ["person_id"], name: "index_item_requests_on_person_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.bigint "region_id", null: false
    t.decimal "longitude", precision: 10, scale: 7
    t.decimal "latitude", precision: 10, scale: 7
    t.text "info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "status", default: "active", null: false, enum_type: "location_status_type"
    t.enum "location_type", default: "regular", null: false, enum_type: "location_type"
    t.integer "estimated_person_count", default: 0, null: false
    t.index ["region_id"], name: "index_locations_on_region_id"
  end

  create_table "menu_items", force: :cascade do |t|
    t.integer "priority_order"
    t.string "name"
    t.string "url"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "item_type", null: false, enum_type: "menu_item_type"
  end

  create_table "packages", force: :cascade do |t|
    t.bigint "receiver_id", null: false
    t.enum "status", default: "packing", null: false, enum_type: "package_status_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "delivered_at"
    t.string "delivered_by"
    t.index ["receiver_id"], name: "index_packages_on_receiver_id"
  end

  create_table "people", force: :cascade do |t|
    t.string "first_name"
    t.bigint "location_id"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "requests_status", null: false, enum_type: "request_status_type"
    t.string "last_name"
    t.string "phone_number"
    t.boolean "active", default: true
    t.boolean "long_term_provisions", default: false, null: false
    t.integer "sparkling_water", default: 0, null: false
    t.integer "still_water", default: 0, null: false
    t.text "book_preferences"
    t.integer "soups", default: 0, null: false
    t.integer "chocolates", default: 0, null: false
    t.integer "sandwiches", default: 0, null: false
    t.index ["code"], name: "index_people_on_code", unique: true
    t.index ["location_id"], name: "index_people_on_location_id"
  end

  create_table "people_visit_summaries", force: :cascade do |t|
    t.bigint "visit_summary_id", null: false
    t.bigint "person_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_people_visit_summaries_on_person_id"
    t.index ["visit_summary_id"], name: "index_people_visit_summaries_on_visit_summary_id"
  end

  create_table "person_sizes", force: :cascade do |t|
    t.bigint "item_category_id", null: false
    t.bigint "person_id", null: false
    t.string "size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_category_id"], name: "index_person_sizes_on_item_category_id"
    t.index ["person_id"], name: "index_person_sizes_on_person_id"
  end

  create_table "preparation_templates", force: :cascade do |t|
    t.string "name", null: false
    t.text "content_html", null: false
    t.boolean "default", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "regions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trip_destination_animals", force: :cascade do |t|
    t.bigint "trip_destination_id", null: false
    t.bigint "animal_id"
    t.string "name", default: "", null: false
    t.string "species", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["animal_id"], name: "index_trip_destination_animals_on_animal_id"
    t.index ["trip_destination_id"], name: "index_trip_destination_animals_on_trip_destination_id"
  end

  create_table "trip_destination_people", force: :cascade do |t|
    t.bigint "trip_destination_id", null: false
    t.bigint "person_id"
    t.string "first_name"
    t.string "last_name"
    t.integer "soups", default: 0, null: false
    t.integer "sandwiches", default: 0, null: false
    t.integer "chocolates", default: 0, null: false
    t.integer "sparkling_water", default: 0, null: false
    t.integer "still_water", default: 0, null: false
    t.boolean "long_term_provisions", default: false, null: false
    t.text "book_preferences"
    t.integer "package_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_trip_destination_people_on_person_id"
    t.index ["trip_destination_id"], name: "index_trip_destination_people_on_trip_destination_id"
  end

  create_table "trip_destinations", force: :cascade do |t|
    t.bigint "trip_group_id", null: false
    t.bigint "location_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "soups", default: 0
    t.integer "provisions", default: 0
    t.integer "books", default: 0
    t.integer "waters", default: 0
    t.text "additional_info"
    t.integer "sandwiches", default: 0
    t.jsonb "location_snapshot"
    t.integer "order"
    t.integer "chocolates", default: 0, null: false
    t.integer "person_count", default: 0, null: false
    t.integer "package_count", default: 0, null: false
    t.integer "animal_count", default: 0, null: false
    t.index ["location_id"], name: "index_trip_destinations_on_location_id"
    t.index ["trip_group_id", "location_id"], name: "index_trip_destinations_on_trip_group_id_and_location_id", unique: true
    t.index ["trip_group_id", "order"], name: "index_trip_destinations_on_trip_group_id_and_order", unique: true
    t.index ["trip_group_id"], name: "index_trip_destinations_on_trip_group_id"
  end

  create_table "trip_groups", force: :cascade do |t|
    t.string "volunteers", null: false, array: true
    t.bigint "trip_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "number"
    t.index ["trip_id"], name: "index_trip_groups_on_trip_id"
  end

  create_table "trips", force: :cascade do |t|
    t.string "source_spreadsheet_url", null: false
    t.date "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "admin_user_id", null: false
    t.boolean "active", default: false
    t.text "preparations_html"
    t.bigint "preparation_template_id"
    t.index ["admin_user_id"], name: "index_trips_on_admin_user_id"
    t.index ["preparation_template_id"], name: "index_trips_on_preparation_template_id"
  end

  create_table "visit_summaries", force: :cascade do |t|
    t.bigint "location_id", null: false
    t.date "visit_date", null: false
    t.string "content", null: false
    t.string "author", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_visit_summaries_on_location_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "animals", "locations"
  add_foreign_key "book_package_items", "book_packages"
  add_foreign_key "book_package_items", "books"
  add_foreign_key "book_packages", "people", column: "receiver_id"
  add_foreign_key "item_requests", "item_categories"
  add_foreign_key "item_requests", "packages"
  add_foreign_key "item_requests", "people"
  add_foreign_key "locations", "regions"
  add_foreign_key "packages", "people", column: "receiver_id"
  add_foreign_key "people", "locations"
  add_foreign_key "people_visit_summaries", "people", on_delete: :cascade
  add_foreign_key "people_visit_summaries", "visit_summaries", on_delete: :cascade
  add_foreign_key "person_sizes", "item_categories"
  add_foreign_key "person_sizes", "people"
  add_foreign_key "trip_destination_animals", "animals", on_delete: :nullify
  add_foreign_key "trip_destination_animals", "trip_destinations"
  add_foreign_key "trip_destination_people", "people", on_delete: :nullify
  add_foreign_key "trip_destination_people", "trip_destinations"
  add_foreign_key "trip_destinations", "locations"
  add_foreign_key "trip_destinations", "trip_groups"
  add_foreign_key "trip_groups", "trips"
  add_foreign_key "trips", "admin_users"
  add_foreign_key "trips", "preparation_templates"
end
