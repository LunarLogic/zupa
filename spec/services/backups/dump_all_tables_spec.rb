require "rails_helper"

RSpec.describe Backups::DumpAllTables do
  it "returns a CSV string per non-internal table keyed by filename" do
    create(:location)
    create(:person)

    files = described_class.new.call

    expect(files).to be_a(Hash)
    expect(files.keys).to include("people.csv", "locations.csv")
    expect(files.keys).not_to include("schema_migrations.csv", "ar_internal_metadata.csv")

    expect(files.values).to all(be_a(String))
  end

  it "produces CSVs whose first row is the column headers and includes seeded rows" do
    location = create(:location)

    csv = described_class.new.call.fetch("locations.csv")
    parsed = CSV.parse(csv)

    expect(parsed.first).to include("id")
    expect(parsed.size).to be >= 2
    ids_column = parsed.first.index("id")
    data_rows = parsed[1..]
    expect(data_rows.map { |row| row[ids_column].to_i }).to include(location.id)
  end
end
