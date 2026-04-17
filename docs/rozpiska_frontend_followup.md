# Rozpiska wolontariuszy — frontend followup

## Status

Deferred from the `feat/trip-preparations-2` feedback round. The backend now stores
per-person flags (`long_term_provisions`, `sparkling_water_count`, `still_water_count`,
`book_preferences`) and exposes them through the Mustache context used by the admin
preparations doc. The volunteer-facing rozpiska (`/trips/:id`) has not been updated
yet — this doc captures what needs to happen next.

## Goal

Surface per-person packing info in the rozpiska so volunteers in the field can see
*for whom* each item is, without having to cross-reference the printed preparations
doc.

Examples from the zupa team:

- "Woda: gazowana dla Jaromiry, Jan; niegazowana dla Anny"
- "Prowiant długoterminowy: Jan K., Anna W."
- "Paczka z Magazynu Ciepła: Jan K."

## API changes

File: `app/views/api/v1/trips/_group.json.jbuilder`

Add a `people` array (if not already present) on each destination (or on the group,
TBD) containing:

- `id`
- `first_name`, `last_name`, `name` (full)
- `long_term_provisions` — boolean
- `sparkling_water_count` — integer
- `still_water_count` — integer
- `book_preferences` — string or null
- `has_package` — derived from `packed_packages.any?`

The Rails controller already eager-loads `active_people` and their `packed_packages`
(`app/controllers/api/v1/trips_controller.rb:6-16`) — no N+1 change needed for the
package flag. If the frontend asks for book preferences, no extra query is needed
(column lives on `people`).

## Frontend changes

Components:

- `app/javascript/components/organisms/TripGroupsList/TripGroupsList.tsx` — add a
  compact per-person chip row under each destination (or group card). Chips:
  - "Prowiant długoterminowy" (when `long_term_provisions`)
  - "Woda gazowana × N" / "Woda niegazowana × N" (when counts > 0)
  - "Paczka z MC" (when `has_package`)
- `app/javascript/pages/GroupDetails/GroupDetails.tsx` — detailed per-person list.
  Group people by destination; show chips + book_preferences line when present.

Types:

- `app/javascript/types/` — extend Person / Group types with the new fields.

## String formats

Aggregated strings requested by the team (for group-level cards that don't render a
per-person list):

- `"Woda: gazowana dla Jaromiry (2), Jan (1); niegazowana dla Anny (3)"`
  — join names with ", " inside each type; separate types with "; "
- `"Prowiant długoterminowy: Jan K., Anna W."`
- `"Paczka z MC: Jan K., Anna W."`

These already exist server-side on `TripGroupDecorator#sparkling_water_recipients`,
`still_water_recipients`, `long_term_provisions_recipients`, `package_recipients`
— consider exposing them via the jbuilder as pre-formatted strings if the frontend
prefers not to assemble them client-side.

## Testing

- Jest unit tests for any new helper that assembles chips/strings
- Update existing tests that snapshot `TripGroupsList` or `GroupDetails`
- Manual: log in as volunteer, open current trip, confirm chips render and match
  what the admin preparations doc says for the same trip

## Out of scope

- Persistent book requests / Mobile Library integration — book preferences are a
  stopgap text field; full integration is a separate initiative.
- Dropping `trip_destinations.waters` column — still exists in schema; follow-up
  migration after confirming prod data is migrated.
