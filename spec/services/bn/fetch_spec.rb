require "rails_helper"
require "webmock/rspec"

RSpec.describe Bn::Fetch do
  describe ".normalize_isbn" do
    it "strips non-digit characters and upcases X" do
      expect(described_class.normalize_isbn("978-83-7578-065-9")).to eq "9788375780659"
      expect(described_class.normalize_isbn("012345678x")).to eq "012345678X"
    end
  end

  describe "#valid?" do
    it "accepts ISBN-10 and ISBN-13" do
      expect(described_class.new("9788375780659").valid?).to be true
      expect(described_class.new("0140449266").valid?).to be true
      expect(described_class.new("014044926X").valid?).to be true
    end

    it "rejects junk" do
      expect(described_class.new("abc").valid?).to be false
      expect(described_class.new("12345").valid?).to be false
    end
  end

  describe "#call" do
    it "returns nil for invalid ISBN without hitting upstream" do
      expect(described_class.new("abc").call).to be_nil
    end

    context "when BN returns a normalized Polish bib via MARC fields" do
      let(:body) do
        {
          bibs: [{
            isbnIssn: "9788375780659",
            title: "Krew elfów / Wiedźmin 3",
            author: "Sapkowski, Andrzej (1948- ) SuperNowa Sapkowski, Andrzej (1948- ).",
            publisher: "SuperNowa SuperNOWA,",
            placeOfPublication: "Warszawa : Polska",
            publicationYear: "2014",
            marc: {
              fields: [
                {"100": {ind1: "1", ind2: " ", subfields: [{a: "Sapkowski, Andrzej"}, {d: "(1948- )"}]}},
                {"245": {ind1: "1", ind2: "0", subfields: [{a: "Krew elfów /"}, {c: "Andrzej Sapkowski."}]}},
                {"260": {ind1: " ", ind2: " ", subfields: [{a: "Warszawa :"}, {b: "SuperNOWA,"}, {c: "copyright 2014."}]}},
                {"300": {ind1: " ", ind2: " ", subfields: [{a: "339, [1] strona ;"}, {c: "20 cm."}]}}
              ]
            }
          }]
        }.to_json
      end

      before do
        WebMock.stub_request(:get, /data.bn.org.pl/).to_return(status: 200, body: body)
      end

      it "extracts title, author, publisher, year, and pages from MARC" do
        result = described_class.new("9788375780659").call
        expect(result.title).to eq "Krew elfów"
        expect(result.author).to eq "Andrzej Sapkowski"
        expect(result.publisher).to eq "SuperNOWA"
        expect(result.pub_year).to eq 2014
        expect(result.length).to eq 339
        expect(result.cover_url).to be_nil
        expect(result.isbn).to eq "9788375780659"
      end
    end

    context "when MARC is absent and only flat fields are present" do
      let(:body) do
        {
          bibs: [{
            isbnIssn: "9788373271234",
            title: "Lalka",
            author: "Prus, Bolesław (1847-1912).",
            publisher: "PIW,",
            publicationYear: "1890"
          }]
        }.to_json
      end

      before do
        WebMock.stub_request(:get, /data.bn.org.pl/).to_return(status: 200, body: body)
      end

      it "falls back to flat fields with cleanup" do
        result = described_class.new("9788373271234").call
        expect(result.title).to eq "Lalka"
        expect(result.author).to eq "Bolesław Prus"
        expect(result.publisher).to eq "PIW"
        expect(result.pub_year).to eq 1890
        expect(result.length).to be_nil
      end
    end

    it "returns nil when bibs array is empty" do
      WebMock.stub_request(:get, /data.bn.org.pl/).to_return(status: 200, body: {bibs: []}.to_json)
      expect(described_class.new("9780000000000").call).to be_nil
    end

    it "returns nil on HTTP error response" do
      WebMock.stub_request(:get, /data.bn.org.pl/).to_return(status: 500)
      expect(described_class.new("9788375780659").call).to be_nil
    end

    it "returns nil on network timeout" do
      WebMock.stub_request(:get, /data.bn.org.pl/).to_raise(Net::OpenTimeout)
      expect(described_class.new("9788375780659").call).to be_nil
    end

    it "returns nil on SSL error" do
      WebMock.stub_request(:get, /data.bn.org.pl/).to_raise(OpenSSL::SSL::SSLError)
      expect(described_class.new("9788375780659").call).to be_nil
    end

    it "returns nil on malformed JSON" do
      WebMock.stub_request(:get, /data.bn.org.pl/).to_return(status: 200, body: "<<not json>>")
      expect(described_class.new("9788375780659").call).to be_nil
    end

    it "strips non-digit characters from ISBN before querying" do
      WebMock.stub_request(:get, %r{isbnIssn=9788375780659}).to_return(status: 200, body: {bibs: []}.to_json)
      described_class.new("978-83-7578-065-9").call
      expect(a_request(:get, %r{isbnIssn=9788375780659})).to have_been_made
    end

    it "caches the result for repeat calls" do
      WebMock.stub_request(:get, /data.bn.org.pl/).to_return(status: 200, body: {bibs: []}.to_json)
      Rails.cache.clear
      original = Rails.cache
      Rails.cache = ActiveSupport::Cache::MemoryStore.new
      begin
        described_class.new("9788375780659").call
        described_class.new("9788375780659").call
      ensure
        Rails.cache = original
      end
      expect(a_request(:get, /data.bn.org.pl/)).to have_been_made.once
    end
  end
end
