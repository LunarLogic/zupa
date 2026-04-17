# Admin trips BETA — handoff

Branch: `feat/admin-trip-form`
Ostatni commit: `2691e80` (Add admin BETA flow for manually creating trips)
Flipper: `:trips_beta` (auto-enabled w test; w dev włącz ręcznie w `/admin/flipper`)

## Co już działa

Druga ścieżka tworzenia wyjazdu — admin formularz bez arkusza Google. Stara ścieżka (`Trip.sheet`) nietknięta — ma osobną sekcję `Wyjazdy`; nowa idzie przez `Wyjazdy BETA` (za flipperem).

- Model `Volunteer` (first_name, last_name, active) + dwa HABTM do `TripGroup`:
  `volunteers` (tabela `trip_groups_volunteers`) i `drivers` (tabela `trip_groups_drivers`).
  Usuwanie Volunteer zablokowane `before_destroy` gdy jest w którejkolwiek grupie.
- `Trip.source` enum `{sheet, manual}`, default `sheet`. Walidacja `source_spreadsheet_url` tylko dla sheet. Manual wymaga co najmniej 1 grupy.
- `TripGroup` — HABTM `volunteers`/`drivers`, `accepts_nested_attributes_for :trip_destinations`, walidacja `trip_destinations >= 1` dla manual.
- `TripDestination#populate_frozen_counts` — `before_validation` policzone `sandwich_count = person_count × AppSetting.sandwiches_per_person`, analogicznie soups/chocolates, plus snapshot lokacji.
- `Trips::PersistManualTrip#call/#update` — zapisuje trip + nested groups + destinations, po save refresh-uje snapshoty ludzi/zwierząt przez `SnapshotPeople`/`SnapshotAnimals`. Auto-numeruje grupy (1..N) na podstawie ich kolejności w paramsach, ignorując `_destroy=1`.
- `Trestle.resource(:trips_beta, model: Trip)` — lista, create/update/delete (delete tylko jeśli `!past_date?`). Kontroler deleguje do `PersistManualTrip`.
- `Trestle.resource(:volunteers)` — CRUD, override `destroy` żeby pokazywać błąd gdy volunteer przypisany.
- Formularz ERB + Stimulus (`app/javascript/admin/controllers/trip_form_controller.js`):
  - `Podstawowe dane` box (data, active, organizator). Data prefillowana na następny czwartek.
  - Grupy w boxach z `✕` top-right do usunięcia. Numer grupy niewidoczny — liczony auto.
  - Wolontariusze + Kierowcy = dwa osobne multi-selecty z tej samej puli (`Volunteer.active`).
  - Lokacje = multi-select. Stimulus sync-uje zaznaczone opcje z kartami destynacji (pick → karta z `additional_info` textarea, unpick → `_destroy=1`). Istniejące destynacje renderują się z prefilowanymi notatkami i zaznaczoną lokacją.
- Frontend React czyta `TripGroup#all_volunteer_names` — w trybie sheet zwraca `volunteer_names` (kolumnę), w trybie manual `volunteers.map(&:full_name)`. Jbuilder bez zmian w strukturze JSON.

## Migracje w tym PR (7 sztuk, pełny zestaw)

1. `20260418120002_add_source_to_trips` — enum
2. `20260418120003_make_trip_source_spreadsheet_url_nullable`
3. `20260418120004_rename_trip_groups_volunteers_to_volunteer_names` — dotknęła `TripRepository`, `TripGroupDecorator`, jbuilder, decoratorów, seeds
4. `20260418120005_create_volunteers`
5. `20260418120006_create_trip_groups_volunteers`
6. `20260418120007_make_trip_group_volunteer_names_nullable` — musiałam, inaczej nowe manual groups padały na NOT NULL
7. `20260418120008_create_trip_groups_drivers`

## Testy

220/220 green. Nowe/zmienione:
- `spec/system/admin/trip_beta_creation_spec.rb` — 11 scenariuszy E2E (Cuprite): happy path, multi-dest, multi-group auto-numbering, next-Thursday prefill, drivers, brak grup_number input, edycja (dodanie dest via multiselect, usunięcie przez unselect), inactive vol pool, flipper menu.
- `spec/services/trips/persist_manual_trip_spec.rb` — auto-numbering, brak grup → RecordInvalid, brak destynacji → RecordInvalid.
- `spec/models/volunteer_spec.rb`, `spec/models/trip_group_spec.rb`.

Uruchomienie: `bundle exec rspec spec/system/admin/trip_beta_creation_spec.rb` (pojedynczy E2E ~18s).

## Co zostaje do zrobienia / decyzje

- **Wyraźne przegadanie designu z klientem.** Obecny UI to rough draft — boxed sections, native `<select multiple>` bez enhancera. Tom-select / Select2 / Choices.js nie ma w projekcie; jeśli klient chce lepszy UX multi-selecta, trzeba to wybrać i podpiąć.
- **Visual QA.** Dual-label bug (Trestle auto-wrap) rozwiązany przez `wrapper: false` na każdym polu. Warto kliknąć przez form w dev żeby zweryfikować że nic nie zostało.
- **Swagger / API docs.** Brak zmian w API, ale jeśli dodamy endpoint do wolontariuszy, trzeba rswag.
- **Locales.** `config/locales/pl.yml` pokryte dla BETA formularza i Volunteer. Angielskie fallbacki z `default:` dla nietłumaczonych przestrzeni nazw — docelowo do ogarnięcia w pl.yml.
- **Frontend drivers.** `_group.json.jbuilder` NIE zwraca drivers — jeśli React ma pokazywać kierowców na rozpisce, trzeba dodać pole. Do potwierdzenia czy to w scope tego PR.
- **Past-date BETA trips.** Edit zawsze dostępny (także po `past_date?`) — świadomie. Bez audit log. Jak klient poprosi, dodać.
- **Location multiselect a kolejność.** Destynacje są tworzone w kolejności klikania w `<select multiple>`. Nie ma reorder UI. Jeśli kolejność destynacji w grupie ma znaczenie (order column?), to nowy PR.
- **Drag-and-drop** grup / destynacji — out of scope.
- **Retire sheet flow** — osobny PR po ustabilizowaniu BETA.
- **Cleanup dead columns** `trip_destinations.provisions/waters/books` — planowane jeszcze z PR 2.
- **Usunięcie Volunteer** — obecnie guard w modelu. UI pokazuje flash error. Brak soft-delete — deactywacja przez `active: false` jest udostępniona.

## Kluczowe pliki do obejrzenia na start

- `app/admin/trips_beta_admin.rb` — Trestle resource + controller
- `app/views/admin/trips_beta/_form.html.erb` + `_group_fields.html.erb` + `_destination_fields.html.erb`
- `app/javascript/admin/controllers/trip_form_controller.js` — Stimulus sync logic
- `app/services/trips/persist_manual_trip.rb` — auto-numbering + snapshot refresh
- `app/models/trip.rb`, `trip_group.rb`, `trip_destination.rb`, `volunteer.rb`
- `spec/system/admin/trip_beta_creation_spec.rb` — E2E patterns (fill_group helper)

## Plan dokument

Pełny plan (decyzje, opcje) w `/Users/tomek/.claude/plans/1-nie-musimy-agile-brook.md`.
