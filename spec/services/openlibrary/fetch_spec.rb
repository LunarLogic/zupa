require "rails_helper"

RSpec.describe Openlibrary::Fetch do
  describe ".normalize_isbn" do
    it "strips non-digit characters" do
      expect(described_class.normalize_isbn("978-0-14-044926-6")).to eq "9780140449266"
    end

    it "upcases X check digit" do
      expect(described_class.normalize_isbn("012345678x")).to eq "012345678X"
    end

    it "handles nil and blank" do
      expect(described_class.normalize_isbn(nil)).to eq ""
      expect(described_class.normalize_isbn("")).to eq ""
    end
  end

  describe "#valid?" do
    it "accepts a 13-digit ISBN" do
      expect(described_class.new("9780140449266").valid?).to be true
    end

    it "accepts a 10-character ISBN-10 with digit check digit" do
      expect(described_class.new("0140449266").valid?).to be true
    end

    it "accepts a 10-character ISBN-10 with X check digit" do
      expect(described_class.new("014044926X").valid?).to be true
    end

    it "rejects junk" do
      expect(described_class.new("abc").valid?).to be false
      expect(described_class.new("12345").valid?).to be false
      expect(described_class.new("99999999999999").valid?).to be false
    end
  end

  describe "#call" do
    it "returns nil for invalid ISBN format without hitting upstream" do
      expect(described_class.new("abc").call).to be_nil
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

    it "returns nil on SSL error" do
      WebMock.stub_request(:get, /openlibrary.org/).to_raise(OpenSSL::SSL::SSLError)
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

  describe "cover URL fallback" do
    let(:isbn) { "9780140449266" }

    def stub_payload(cover_hash)
      payload = {"ISBN:#{isbn}" => {"title" => "Test", "cover" => cover_hash}.compact}
      WebMock.stub_request(:get, /openlibrary.org/).to_return(
        status: 200, body: payload.to_json, headers: {"Content-Type" => "application/json"}
      )
    end

    it "prefers the large cover" do
      stub_payload("large" => "https://example.com/L.jpg", "medium" => "https://example.com/M.jpg", "small" => "https://example.com/S.jpg")
      expect(described_class.new(isbn).call.cover_url).to eq "https://example.com/L.jpg"
    end

    it "falls back to medium when large is missing" do
      stub_payload("medium" => "https://example.com/M.jpg", "small" => "https://example.com/S.jpg")
      expect(described_class.new(isbn).call.cover_url).to eq "https://example.com/M.jpg"
    end

    it "falls back to small when only small is present" do
      stub_payload("small" => "https://example.com/S.jpg")
      expect(described_class.new(isbn).call.cover_url).to eq "https://example.com/S.jpg"
    end

    it "returns nil cover_url when payload has no cover" do
      stub_payload(nil)
      expect(described_class.new(isbn).call.cover_url).to be_nil
    end
  end

  describe "pub_year extraction" do
    let(:isbn) { "9780140449266" }

    def stub_publish_date(date_string)
      payload = {"ISBN:#{isbn}" => {"title" => "Test", "publish_date" => date_string}}
      WebMock.stub_request(:get, /openlibrary.org/).to_return(
        status: 200, body: payload.to_json, headers: {"Content-Type" => "application/json"}
      )
    end

    it "extracts a bare year" do
      stub_publish_date("2010")
      expect(described_class.new(isbn).call.pub_year).to eq 2010
    end

    it "extracts year from a 'March 2010' style" do
      stub_publish_date("March 2010")
      expect(described_class.new(isbn).call.pub_year).to eq 2010
    end

    it "ignores implausible 4-digit numbers" do
      stub_publish_date("First printing of 5000 copies, 2010")
      expect(described_class.new(isbn).call.pub_year).to eq 2010
    end

    it "returns nil when no plausible year is present" do
      stub_publish_date("Q3 fiscal")
      expect(described_class.new(isbn).call.pub_year).to be_nil
    end

    it "returns nil when publish_date is missing" do
      payload = {"ISBN:#{isbn}" => {"title" => "Test"}}
      WebMock.stub_request(:get, /openlibrary.org/).to_return(
        status: 200, body: payload.to_json, headers: {"Content-Type" => "application/json"}
      )
      expect(described_class.new(isbn).call.pub_year).to be_nil
    end
  end
end
