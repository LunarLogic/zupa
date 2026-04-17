# PR #15 — notatki z review

Branch: `feat/trip-destination-people-snapshot`
PR: https://github.com/LunarLogic/zupa/pull/15

## Co zrobiliśmy w skrócie

Odłączenie rozpiski wolontariusza od arkusza Google — liczby kanapek/zup liczą się z `AppSetting × liczba osób`, a teksty "Prowiant/Woda/Książki" budują się z nowej tabeli snapshotowej `trip_destination_people`. Arkusz dostarcza już tylko strukturę grup + uwagi dodatkowe (col 8).

## Ryzyko i rollout

- **Migracja additive** — nowa tabela + kolumna `soups_per_person` z defaultem 1. Nic nie pęknie na starych danych.
- **Stare wyjazdy bez backfillu** — ich `additional_info` zostaje taki jak stare parser arkusza zrobił. Intencjonalnie, zgodnie z decyzją ("zostaw puste").
- **Dead kolumny** `trip_destinations.provisions/waters/books` nie używane, ale zostają. Do usunięcia w osobnym PR razem z `Trips::ParseCell` paths.
- **Walidacja nagłówków usunięta** — arkusz nie musi już mieć kolumn "kanapki/zupy/prow/woda/książki/uwagi" w nagłówkach. Ale parser dalej czyta po indeksie (col 8 = uwagi). Jeśli ktoś przestawi kolumnę uwag, dostaniemy zły tekst w `additional_info`. Akceptowalne krótko-terminowo (liczby z DB nie ucierpią), ale warto wiedzieć.

## Edge cases — co to znaczy w praktyce

### 1. `package_count` zamrożony w momencie tworzenia wyjazdu

Co robi: `SnapshotPeople` kopiuje `person.packed_packages.size` do `trip_destination_people.package_count`.

**Problem**: jak admin stworzy wyjazd w poniedziałek, a paczkę dla danej osoby spakuje we wtorek — paczka nie pojawi się na rozpisce tego wyjazdu. Rozpiska pokaże "ta osoba ma 0 paczek", nawet jeśli w DB mają paczkę gotową.

**Czy to problem?** Stare zachowanie (arkusz parsowany raz przy starcie) robiło tak samo — rozpiska była migawką. Nowe zachowanie to samo, tylko źródłem jest DB zamiast arkusza. **Zgodne z intencją historycznej immutowalności.**

**Kiedy to ugryzie**: jeśli wolontariusze zaczną pakować paczki w drodze (po wydruku rozpiski) albo dzień po stworzeniu wyjazdu, trzeba będzie przemyśleć — albo edytować snapshot ręcznie, albo pozwolić `UpdateTrip` przelcizyć snapshot (ale to już jest — update wywala i tworzy na nowo).

### 2. `water_count` robi 2 zapytania SQL zamiast jednego

Co robi: `trip_destination_people.sum(:sparkling_water_count) + trip_destination_people.sum(:still_water_count)` → dwa `SELECT SUM(...)` zamiast jednego `SELECT SUM(a + b)`.

**Problem**: w serializerze wywołujemy to raz na destynację. Dla wyjazdu z 30 destynacjami to 60 dodatkowych queryes zamiast 30. W skali naszej aplikacji (parę wyjazdów dziennie, kilkudziesięciu lokacji każdy) — **niewidoczne**.

**Fix gdy zaboli**: jeden query `SUM(sparkling_water_count + still_water_count)` albo `includes(:trip_destination_people)` + sumowanie w Ruby.

### 3. Estymowane lokacje mają pusty snapshot ludzi

Co robi: `SnapshotPeople` iteruje po `location.active_people`. Dla lokacji typu `estimated` (nowe z PR#1) `active_people` zwraca pustą listę (bo nie trzymamy tam osób imiennie, tylko `estimated_person_count: 10`).

**Skutek**:
- `sandwich_count` / `soup_count` — **poprawne**, bo idzie z `person_count × AppSetting`, a `person_count` dla `estimated` == `estimated_person_count`.
- `long_term_provisions_recipients` — **puste**. Rozpiska nie pokaże "Prowiant: ..." dla estymowanej lokacji.
- `sparkling_water_recipients` / `still_water_recipients` — puste.
- `package_recipients`, `book_recipients` — puste.

**Czy to problem?** Na razie nie — estymowane lokacje mają być dla miejsc typu "pod wiaduktem, ok. 10 osób bez imion". Tam z założenia nie znamy kto potrzebuje prowiantu długoterminowego. Intencjonalne.

**Kiedy ugryzie**: jeśli zechcemy mieć estymowaną lokację z dodatkowymi informacjami typu "3 z 10 chce kawy", trzeba będzie rozszerzyć model — albo dodać pole `estimated_notes` na lokacji, albo pozwolić na częściowo imienne osoby przy estymowanych.

## Testy — co jest chakeredowane

### VCR cassette reuse

System spec `spec/system/admin/trip_creation_from_spreadsheet_spec.rb` używa cassette z service speca (`spec/services/trips/create_trip_spec.rb`). Nie ma dwóch kopii HTTP recordings. Jeśli arkusz się zmieni i trzeba przenagrywać — przenagraj raz (service spec), obydwa testy podchwycą.

### Inactive Person hack w API spec

`spec/requests/api/v1/trips_spec.rb` tworzy dodatkowe `Person` (p2, p3) z `:inactive` jako snapshot-owych osób, żeby counts się zgadzały. Robimy to tak bo `location.person_count` delegates do `location.active_people.count` — a test assertion `expect(location_json["person_count"]).to eq 1` wymaga tylko 1 active. Inactive nie liczą się do `person_count`, ale snapshot'y zostają w `trip_destination_people`.

**Alternatywa (czystsza)**: przepisać test żeby nie asercjonował `person_count == 1` i pozwolić snapshotowi być głównym source. Pozostawiono obecną formę żeby nie zmieniać scope'u PR-a.

## Nice-to-have, nie blokuje merge'a

- **Duplikacja formatterów** — `ComposeAdditionalInfo` ma własne `provisions_line`, `water_line`, `books_line`. Równoległe `TripGroupDecorator#sparkling_water_recipients` etc. też formatują ludzi. Wspólny presenter byłby czystszy. Na razie inline stringi są czytelne.
- **Dwustopniowy create + update w `TripRepository`** — najpierw `TripDestination.create!` z pustym `additional_info`, potem `SnapshotPeople`, potem `update!(additional_info: Compose...)`. Chcieliśmy tego uniknąć, ale `ComposeAdditionalInfo` potrzebuje snapshotu, a snapshot potrzebuje już utworzonej destynacji. Pragmatycznie.

## Co dalej (po merge'u)

1. Drop dead columns `provisions/waters/books` + usunięcie parse paths.
2. Admin UI do tworzenia wyjazdu bez arkusza (PR 3 w planie).
3. Shared presenter dla per-person formatowania jeśli dodamy więcej pól.
