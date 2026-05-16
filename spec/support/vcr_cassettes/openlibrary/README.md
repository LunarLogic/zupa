# OpenLibrary VCR cassettes

Cassettes for `Openlibrary::Fetch` and `Api::V1::Library::IsbnLookupController`. Recorded against the live `https://openlibrary.org/api/books?bibkeys=ISBN:X&jscmd=data&format=json` endpoint.

## Cassettes

| File | ISBN | Backs |
|---|---|---|
| `monte_cristo.yml` | `9780140449266` (The Count of Monte Cristo, Penguin Classics) | the 200 happy-path tests; stable, well-populated metadata |
| `unknown_isbn.yml` | `9788373271005` (Lalka — OpenLibrary returns empty `{}` for this one) | the 404 not-found path |

## Re-recording

Cassettes are pinned with VCR's default `:once` mode — once a `.yml` exists, no new HTTP is performed for that cassette. If OpenLibrary's payload shape changes and tests break:

```bash
rm spec/support/vcr_cassettes/openlibrary/monte_cristo.yml
bundle exec rspec spec/services/openlibrary/fetch_spec.rb spec/requests/api/v1/library/isbn_lookup_spec.rb
```

`spec/spec_helper.rb` has `allow_http_connections_when_no_cassette = true` so missing cassettes record fresh on the next run. Commit the regenerated YAML.

## Last recorded

2026-05-16 against live OpenLibrary.
