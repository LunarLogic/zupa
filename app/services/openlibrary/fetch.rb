require "net/http"
require "json"

module Openlibrary
  # Fetches book metadata from the public OpenLibrary "books" endpoint and
  # normalizes the response into a flat struct that matches our Book fields.
  # Returns nil when the upstream has no record for the ISBN or the request
  # fails — callers translate that to 404.
  class Fetch
    Result = Struct.new(
      :isbn, :title, :author, :length, :publisher, :pub_year, :cover_url,
      keyword_init: true
    )

    BASE_URL = "https://openlibrary.org/api/books".freeze
    TIMEOUT_SECONDS = 5

    def initialize(isbn)
      @isbn = isbn.to_s.gsub(/[^0-9X]/i, "")
    end

    def call
      return nil if @isbn.blank?

      response = http_get
      return nil unless response.is_a?(Net::HTTPSuccess)

      payload = JSON.parse(response.body)[key]
      return nil if payload.blank?

      normalize(payload)
    rescue JSON::ParserError, Net::OpenTimeout, Net::ReadTimeout, SocketError, Errno::ECONNREFUSED
      nil
    end

    private

    def key
      "ISBN:#{@isbn}"
    end

    def http_get
      uri = URI("#{BASE_URL}?bibkeys=#{key}&jscmd=data&format=json")
      Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: TIMEOUT_SECONDS, read_timeout: TIMEOUT_SECONDS) do |http|
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

    def extract_year(publish_date)
      return nil if publish_date.blank?
      match = publish_date.to_s.match(/\b(\d{4})\b/)
      match && match[1].to_i
    end
  end
end
