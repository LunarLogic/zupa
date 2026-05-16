require "net/http"
require "json"

module Openlibrary
  # Fetches book metadata from the public OpenLibrary "books" endpoint and
  # normalizes the response into a flat struct that matches our Book fields.
  # Returns nil when the upstream has no record for the ISBN, the request
  # fails, or the input is not a well-formed ISBN — callers translate that
  # to 404 (no record) vs 422 (bad input) via `#valid?`.
  class Fetch
    Result = Struct.new(
      :isbn, :title, :author, :length, :publisher, :pub_year, :cover_url,
      keyword_init: true
    )

    ISBN_FORMATS = [
      /\A\d{9}[\dX]\z/, # ISBN-10 (digits, last char may be the X check digit)
      /\A\d{13}\z/      # ISBN-13
    ].freeze

    DEFAULT_BASE_URL = "https://openlibrary.org/api/books"
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
      ENV.fetch("OPENLIBRARY_BASE_URL", DEFAULT_BASE_URL)
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
      "openlibrary/isbn/#{@isbn}"
    end

    def upstream_key
      "ISBN:#{@isbn}"
    end

    def fetch_from_upstream
      response = http_get
      return nil unless response.is_a?(Net::HTTPSuccess)

      payload = JSON.parse(response.body)[upstream_key]
      return nil if payload.blank?

      normalize(payload)
    rescue *NETWORK_ERRORS
      nil
    end

    def http_get
      uri = URI("#{self.class.base_url}?bibkeys=#{upstream_key}&jscmd=data&format=json")
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
        open_timeout: TIMEOUT_SECONDS, read_timeout: TIMEOUT_SECONDS) do |http|
        http.get(uri.request_uri)
      end
    end

    def normalize(payload)
      Result.new(
        isbn: @isbn,
        title: payload["title"].presence,
        author: extract_author(payload),
        length: payload["number_of_pages"],
        publisher: Array(payload["publishers"]).first&.dig("name"),
        pub_year: extract_year(payload["publish_date"]),
        cover_url: payload.dig("cover", "large") ||
          payload.dig("cover", "medium") ||
          payload.dig("cover", "small")
      )
    end

    def extract_author(payload)
      names = Array(payload["authors"]).map { |a| a["name"] }.compact_blank
      names.empty? ? nil : names.join(", ")
    end

    # Picks the last plausible 4-digit year from the publish_date string.
    # `\b\d{4}\b` alone over-matches things like "5000 copies, 2010" — we
    # scan all candidates and take the last one inside a sane year range.
    def extract_year(publish_date)
      return nil if publish_date.blank?

      candidates = publish_date.to_s.scan(/\b(\d{4})\b/).flatten.map(&:to_i)
      candidates.reverse.find { |y| PLAUSIBLE_YEAR_RANGE.cover?(y) }
    end
  end
end
