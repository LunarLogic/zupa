import { useMemo, useState } from "react";

import type { Bootstrap, GroupState, LocationOption, Option } from "./types";

const PALETTE = [
  "#e74c3c",
  "#3498db",
  "#2ecc71",
  "#f39c12",
  "#9b59b6",
  "#1abc9c",
  "#d35400",
  "#34495e",
];

function nextThursdayISO(): string {
  const today = new Date();
  const daysAhead = (4 - today.getDay() + 7) % 7 || 7; // 4 = Thursday
  const target = new Date(today);
  target.setDate(today.getDate() + daysAhead);
  return target.toISOString().slice(0, 10);
}

function emptyGroup(): GroupState {
  return { locationIds: [], driverIds: [], volunteerIds: [] };
}

function RecencyBadge({ rank }: { rank: number | null }) {
  if (rank === 0) return <span style={{ ...badge, background: "#27ae60" }}>ostatni wyjazd</span>;
  if (rank === 1) return <span style={{ ...badge, background: "#f39c12" }}>2 wyjazdy temu</span>;
  return null;
}

export default function TripBuilder({ data }: { data: Bootstrap }) {
  const [date, setDate] = useState<string>(nextThursdayISO());
  const [organiserId, setOrganiserId] = useState<number>(data.currentUserId);
  const [groups, setGroups] = useState<GroupState[]>([emptyGroup()]);
  const [errors, setErrors] = useState<string[]>([]);
  const [submitting, setSubmitting] = useState(false);

  const locationsById = useMemo(() => {
    const map = new Map<number, LocationOption>();
    data.locations.forEach((l) => map.set(l.id, l));
    return map;
  }, [data.locations]);

  const updateGroup = (index: number, patch: Partial<GroupState>) => {
    setGroups((prev) => prev.map((g, i) => (i === index ? { ...g, ...patch } : g)));
  };

  const addGroup = () => setGroups((prev) => [...prev, emptyGroup()]);

  const removeGroup = (index: number) =>
    setGroups((prev) => (prev.length === 1 ? prev : prev.filter((_, i) => i !== index)));

  const locationsTakenElsewhere = (index: number): Set<number> => {
    const taken = new Set<number>();
    groups.forEach((g, i) => {
      if (i !== index) g.locationIds.forEach((id) => taken.add(id));
    });
    return taken;
  };

  const canSubmit =
    date !== "" && organiserId != null && groups.some((g) => g.locationIds.length > 0);

  const submit = async () => {
    setSubmitting(true);
    setErrors([]);
    try {
      const response = await fetch(data.createUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": data.csrfToken,
          Accept: "application/json",
        },
        body: JSON.stringify({
          date,
          admin_user_id: organiserId,
          groups: groups
            .filter((g) => g.locationIds.length > 0)
            .map((g) => ({
              location_ids: g.locationIds,
              driver_ids: g.driverIds,
              volunteer_ids: g.volunteerIds,
            })),
        }),
      });

      const payload = await response.json();
      if (response.ok && payload.redirect_to) {
        window.location.href = payload.redirect_to;
      } else {
        setErrors(payload.errors || ["Nie udało się utworzyć wyjazdu."]);
        setSubmitting(false);
      }
    } catch (e) {
      setErrors(["Błąd sieci. Spróbuj ponownie."]);
      setSubmitting(false);
    }
  };

  return (
    <div style={{ maxWidth: 900 }}>
      {errors.length > 0 && (
        <div className="alert alert-danger" style={{ marginBottom: "1rem" }}>
          <ul style={{ margin: 0, paddingLeft: "1.2rem" }}>
            {errors.map((e, i) => (
              <li key={i}>{e}</li>
            ))}
          </ul>
        </div>
      )}

      <section style={card}>
        <h3 style={heading}>Podstawowe informacje</h3>
        <div style={{ display: "flex", gap: "1.5rem", flexWrap: "wrap" }}>
          <label style={field}>
            <span>Data wyjazdu</span>
            <input
              type="date"
              className="form-control"
              value={date}
              onChange={(e) => setDate(e.target.value)}
            />
          </label>
          <label style={field}>
            <span>Organizator</span>
            <select
              className="form-control"
              value={organiserId}
              onChange={(e) => setOrganiserId(Number(e.target.value))}
            >
              {data.adminUsers.map((u) => (
                <option key={u.id} value={u.id}>
                  {u.name}
                </option>
              ))}
            </select>
          </label>
        </div>
      </section>

      {groups.map((group, index) => {
        const color = PALETTE[index % PALETTE.length];
        const taken = locationsTakenElsewhere(index);
        return (
          <section key={index} style={{ ...card, borderLeft: `4px solid ${color}` }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <h3 style={{ ...heading, color }}>Grupa {index + 1}</h3>
              {groups.length > 1 && (
                <button
                  type="button"
                  className="btn btn-sm btn-danger"
                  onClick={() => removeGroup(index)}
                >
                  Usuń grupę
                </button>
              )}
            </div>

            <LocationPicker
              locations={data.locations}
              selected={group.locationIds}
              taken={taken}
              onToggle={(id) => {
                const has = group.locationIds.includes(id);
                updateGroup(index, {
                  locationIds: has
                    ? group.locationIds.filter((x) => x !== id)
                    : [...group.locationIds, id],
                });
              }}
              locationsById={locationsById}
            />

            <div style={{ display: "flex", gap: "1.5rem", flexWrap: "wrap", marginTop: "1rem" }}>
              <PeoplePicker
                title="Kierowcy"
                people={data.volunteers}
                selected={group.driverIds}
                onChange={(ids) =>
                  updateGroup(index, {
                    driverIds: ids,
                    volunteerIds: group.volunteerIds.filter((v) => !ids.includes(v)),
                  })
                }
              />
              <PeoplePicker
                title="Pomocnicy"
                people={data.volunteers.filter((v) => !group.driverIds.includes(v.id))}
                selected={group.volunteerIds}
                onChange={(ids) => updateGroup(index, { volunteerIds: ids })}
              />
            </div>
          </section>
        );
      })}

      <button
        type="button"
        className="btn btn-secondary"
        onClick={addGroup}
        style={{ marginBottom: "1.5rem" }}
      >
        + Dodaj grupę
      </button>

      <div>
        <button
          type="button"
          className="btn btn-success btn-lg"
          disabled={!canSubmit || submitting}
          onClick={submit}
        >
          {submitting ? "Tworzę…" : "Utwórz wyjazd"}
        </button>
      </div>
    </div>
  );
}

function LocationPicker({
  locations,
  selected,
  taken,
  onToggle,
  locationsById,
}: {
  locations: LocationOption[];
  selected: number[];
  taken: Set<number>;
  onToggle: (id: number) => void;
  locationsById: Map<number, LocationOption>;
}) {
  const [query, setQuery] = useState("");
  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    return locations.filter((l) => (q === "" ? true : l.name.toLowerCase().includes(q)));
  }, [locations, query]);

  return (
    <div>
      <strong>Lokacje</strong>
      {selected.length > 0 && (
        <div style={{ margin: "0.5rem 0", display: "flex", flexWrap: "wrap", gap: "0.4rem" }}>
          {selected.map((id) => (
            <span key={id} style={chip} onClick={() => onToggle(id)} title="Kliknij, aby usunąć">
              {locationsById.get(id)?.name ?? id} ✕
            </span>
          ))}
        </div>
      )}
      <input
        type="text"
        className="form-control"
        placeholder="Szukaj lokacji…"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        style={{ marginBottom: "0.5rem" }}
      />
      <div style={list}>
        {filtered.map((l) => {
          const isSelected = selected.includes(l.id);
          const isTaken = taken.has(l.id);
          return (
            <label key={l.id} style={{ ...listItem, opacity: isTaken ? 0.4 : 1 }}>
              <input
                type="checkbox"
                checked={isSelected}
                disabled={isTaken}
                onChange={() => onToggle(l.id)}
              />
              <span style={{ flex: 1 }}>{l.name}</span>
              <RecencyBadge rank={l.recent_rank} />
            </label>
          );
        })}
        {filtered.length === 0 && (
          <div style={{ padding: "0.5rem", color: "#999" }}>Brak wyników</div>
        )}
      </div>
    </div>
  );
}

function PeoplePicker({
  title,
  people,
  selected,
  onChange,
}: {
  title: string;
  people: Option[];
  selected: number[];
  onChange: (ids: number[]) => void;
}) {
  const toggle = (id: number) => {
    onChange(selected.includes(id) ? selected.filter((x) => x !== id) : [...selected, id]);
  };

  return (
    <div style={{ flex: 1, minWidth: 240 }}>
      <strong>{title}</strong>
      <div style={{ ...list, maxHeight: 160 }}>
        {people.map((p) => (
          <label key={p.id} style={listItem}>
            <input
              type="checkbox"
              checked={selected.includes(p.id)}
              onChange={() => toggle(p.id)}
            />
            <span>{p.name}</span>
          </label>
        ))}
        {people.length === 0 && (
          <div style={{ padding: "0.5rem", color: "#999" }}>Brak wolontariuszy</div>
        )}
      </div>
    </div>
  );
}

const card: React.CSSProperties = {
  background: "#fff",
  border: "1px solid #e5e5e5",
  borderRadius: 6,
  padding: "1.25rem",
  marginBottom: "1.25rem",
};

const heading: React.CSSProperties = { marginTop: 0, marginBottom: "1rem" };

const field: React.CSSProperties = {
  display: "flex",
  flexDirection: "column",
  gap: "0.35rem",
  minWidth: 220,
};

const list: React.CSSProperties = {
  border: "1px solid #ddd",
  borderRadius: 4,
  maxHeight: 220,
  overflowY: "auto",
};

const listItem: React.CSSProperties = {
  display: "flex",
  alignItems: "center",
  gap: "0.5rem",
  padding: "0.4rem 0.6rem",
  borderBottom: "1px solid #f0f0f0",
  cursor: "pointer",
  margin: 0,
};

const chip: React.CSSProperties = {
  background: "#eef4fb",
  border: "1px solid #cfe0f2",
  borderRadius: 12,
  padding: "0.15rem 0.6rem",
  fontSize: "0.85rem",
  cursor: "pointer",
};

const badge: React.CSSProperties = {
  color: "#fff",
  borderRadius: 10,
  padding: "0.1rem 0.5rem",
  fontSize: "0.75rem",
  whiteSpace: "nowrap",
};
