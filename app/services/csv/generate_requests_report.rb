require "csv"

module Csv
  class GenerateRequestsReport
    HEADERS = ["Data zgłoszenia", "Data ostatniej edycji", "Status", "Osoba", "Kategoria", "Komentarz"]

    def call
      item_requests = ItemRequest.includes(:person, :item_category)
      to_csv(item_requests)
    end

    private

    def to_csv(requests)
      CSV.generate(headers: true) do |csv|
        csv << HEADERS

        requests.each do |request|
          csv << to_row(request)
        end
      end
    end

    def to_row(r)
      [
        r.created_at.strftime("%m/%d/%Y"),
        r.updated_at.strftime("%m/%d/%Y"),
        translate(r.status),
        r.person_full_name_with_code,
        r.item_category_name,
        r.comment
      ]
    end

    def translate(status)
      I18n.t(status, scope: :item_request_statuses)
    end
  end
end
