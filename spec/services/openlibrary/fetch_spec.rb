require "rails_helper"

RSpec.describe Openlibrary::Fetch do
  describe "#call" do
    it "returns nil when ISBN is blank" do
      expect(described_class.new("").call).to be_nil
      expect(described_class.new(nil).call).to be_nil
    end

    it "strips non-digit characters from ISBN before querying" do
      VCR.use_cassette("openlibrary/monte_cristo") do
        result = described_class.new("978-0-14-044926-6").call
        expect(result&.isbn).to eq "9780140449266"
      end
    end

    it "returns a normalized Result for a known ISBN" do
      VCR.use_cassette("openlibrary/monte_cristo") do
        result = described_class.new("9780140449266").call
        expect(result).to be_a(described_class::Result)
        expect(result.title).to be_a(String).and(be_present)
        expect(result.author).to be_a(String).and(be_present)
      end
    end

    it "returns nil when OpenLibrary returns an empty payload" do
      VCR.use_cassette("openlibrary/unknown_isbn") do
        expect(described_class.new("9788373271005").call).to be_nil
      end
    end

    it "returns nil on network error" do
      WebMock.stub_request(:get, /openlibrary.org/).to_raise(Net::OpenTimeout)
      expect(described_class.new("9780140449266").call).to be_nil
    end

    it "returns nil on malformed JSON" do
      WebMock.stub_request(:get, /openlibrary.org/).to_return(status: 200, body: "<<not json>>")
      expect(described_class.new("9780140449266").call).to be_nil
    end

    it "returns nil on non-2xx upstream response" do
      WebMock.stub_request(:get, /openlibrary.org/).to_return(status: 503, body: "")
      expect(described_class.new("9780140449266").call).to be_nil
    end
  end
end
