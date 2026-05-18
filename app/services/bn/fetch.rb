require "net/http"
require "json"

module Bn
  # Fetches book metadata from the Polish National Library (Biblioteka Narodowa)
  # public catalogue at data.bn.org.pl and normalizes it into the same Result
  # struct shape as Openlibrary::Fetch so the controller can chain them.
  #
  # Coverage on Polish-published ISBNs is significantly better than OpenLibrary,
  # which is why this is tried first for the Zupa mobile-library use case.
  class Fetch
    Result = Struct.new(
      :isbn, :title, :author, :length, :publisher, :pub_year, :cover_url,
      keyword_init: true
    )

    ISBN_FORMATS = [
      /\A\d{9}[\dX]\z/, # ISBN-10
      /\A\d{13}\z/      # ISBN-13
    ].freeze

    DEFAULT_BASE_URL = "https://data.bn.org.pl/api/networks/bibs.json"
    TIMEOUT_SECONDS = 5
    CACHE_TTL = 1.week
    PLAUSIBLE_YEAR_RANGE = (1500..2099)

    NETWORK_ERRORS = [
      JSON::ParserError,
      Net::OpenTimeout, Net::ReadTimeout, Net::HTTPError,
      OpenSSL::SSL::SSLError,
      SocketError, EOFError, Timeout::Error,
      Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ETIMEDOUT
    ].freeze

    def self.normalize_isbn(raw)
      raw.to_s.gsub(/[^0-9X]/i, "").upcase
    end

    def self.base_url
      ENV.fetch("BN_BASE_URL", DEFAULT_BASE_URL)
    end

    attr_reader :isbn

    def initialize(raw_isbn)
      @isbn = self.class.normalize_isbn(raw_isbn)
    end

    def valid?
      ISBN_FORMATS.any? { |re| @isbn.match?(re) }
    end

    def call
      return nil unless valid?

      Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) { fetch_from_upstream }
    end

    private

    def cache_key
      "bn/isbn/#{@isbn}"
    end

    def fetch_from_upstream
      response = http_get
      return nil unless response.is_a?(Net::HTTPSuccess)

      bibs = JSON.parse(response.body)["bibs"]
      return nil if bibs.blank?

      normalize(bibs.first)
    rescue *NETWORK_ERRORS
      nil
    end

    def http_get
      uri = URI("#{self.class.base_url}?isbnIssn=#{@isbn}&limit=1")
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
        open_timeout: TIMEOUT_SECONDS, read_timeout: TIMEOUT_SECONDS) do |http|
        http.get(uri.request_uri)
      end
    end

    def normalize(bib)
      marc_subfields = index_marc(bib["marc"])
      Result.new(
        isbn: @isbn,
        title: extract_title(bib, marc_subfields),
        author: extract_author(bib, marc_subfields),
        length: extract_length(marc_subfields),
        publisher: extract_publisher(bib, marc_subfields),
        pub_year: extract_year(bib, marc_subfields),
        cover_url: nil # BN does not expose cover images
      )
    end

    # Builds a quick lookup like { "245" => { "a" => "Title /", "c" => "..." }, ... }
    # from the MARC fields array. Repeated subfield codes inside one tag are joined with spaces.
    def index_marc(marc)
      fields = marc.is_a?(Hash) ? Array(marc["fields"]) : []
      index = {}
      fields.each do |entry|
        entry.each do |tag, value|
          next unless value.is_a?(Hash)
          subfields = Array(value["subfields"])
          collected = subfields.each_with_object({}) do |sf, acc|
            sf.each { |code, text| acc[code] = [acc[code], text].compact.join(" ") }
          end
          index[tag] ||= collected
        end
      end
      index
    end

    def extract_title(bib, marc)
      marc_title = marc.dig("245", "a")
      raw = marc_title.presence || bib["title"].to_s
      strip_trailing_punctuation(raw, %w[/ :])
    end

    # MARC 100$a is "Surname, Firstname"; reorder it. The flat `author` field is
    # often duplicated and noisy, so we only fall back to it when MARC is absent.
    def extract_author(bib, marc)
      marc_author = marc.dig("100", "a") || marc.dig("700", "a")
      name = if marc_author.present?
        reorder_surname_first(strip_trailing_punctuation(marc_author, %w[. ,]))
      else
        clean_flat_author(bib["author"])
      end
      name.presence
    end

    def extract_publisher(bib, marc)
      marc_publisher = marc.dig("260", "b") || marc.dig("264", "b")
      raw = marc_publisher.presence || bib["publisher"].to_s
      strip_trailing_punctuation(raw, %w[, .]).presence
    end

    def extract_year(bib, marc)
      candidates = [
        bib["publicationYear"],
        marc.dig("260", "c"),
        marc.dig("264", "c")
      ].compact.flat_map { |s| s.to_s.scan(/\b(\d{4})\b/).flatten }.map(&:to_i)
      candidates.find { |y| PLAUSIBLE_YEAR_RANGE.cover?(y) }
    end

    # MARC 300$a looks like "339, [1] strona ;" or "362, [3] s. ;" — the leading
    # integer is the printed page count. Take the largest plausible number to
    # cope with formats like "XIV, 250 s." where roman numerals precede.
    def extract_length(marc)
      raw = marc.dig("300", "a").to_s
      numbers = raw.scan(/\d+/).map(&:to_i)
      numbers.max
    end

    def reorder_surname_first(name)
      surname, given = name.split(",", 2).map(&:strip)
      given.present? ? "#{given} #{surname}" : surname
    end

    def clean_flat_author(value)
      return "" if value.blank?
      # Flat `author` is often "Surname, Firstname (1948- ) Publisher Surname, Firstname (1948- )."
      # Cut everything from the first "(yyyy...)" parenthetical onward — it always follows
      # the first author and the duplicated tail isn't useful.
      first = value.to_s.sub(/\s*\([^)]*\d{4}[^)]*\).*\z/, "").strip
      first = strip_trailing_punctuation(first, %w[. ,])
      reorder_surname_first(first)
    end

    def strip_trailing_punctuation(value, chars)
      pattern = Regexp.union(chars.map { |c| Regexp.escape(c) })
      value.to_s.sub(/\s*(?:#{pattern})+\s*\z/, "").strip
    end
  end
end
