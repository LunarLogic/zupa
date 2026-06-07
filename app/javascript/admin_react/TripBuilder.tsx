import { useEffect, useMemo, useState } from "react";

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

// v3: volunteerIds now holds ALL group members; driverIds is the subset marked
// as drivers. (v2 drafts used a drivers/helpers split and are discarded.)
const DRAFT_KEY = "zupa.tripBuilder.v3";

interface DraftState {
  date: string;
  organiserId: number;
  groups: GroupState[];
}

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

// Restores a persisted draft, dropping any location/volunteer/organiser ids
// that no longer exist in the current bootstrap so a stale draft can't
// reference deleted records.
function sanitizeDraft(raw: string | null, data: Bootstrap): DraftState | null {
  if (!raw) return null;
  try {
    const parsed = JSON.parse(raw) as Partial<DraftState>;
    if (!Array.isArray(parsed.groups)) return null;

    const locationIds = new Set(data.locations.map((l) => l.id));
    const volunteerIds = new Set(data.volunteers.map((v) => v.id));
    const organiserIds = new Set(data.adminUsers.map((u) => u.id));

    const groups = parsed.groups.map((g) => ({
      locationIds: (g.locationIds || []).filter((id) => locationIds.has(id)),
      driverIds: (g.driverIds || []).filter((id) => volunteerIds.has(id)),
      volunteerIds: (g.volunteerIds || []).filter((id) => volunteerIds.has(id)),
    }));

    return {
      date: parsed.date || nextThursdayISO(),
      organiserId: organiserIds.has(parsed.organiserId as number)
        ? (parsed.organiserId as number)
        : data.currentUserId,
      groups: groups.length > 0 ? groups : [emptyGroup()],
    };
  } catch {
    return null;
  }
}

export default function TripBuilder({ data }: { data: Bootstrap }) {
  const initial = useMemo(
    () =>
      sanitizeDraft(window.localStorage.getItem(DRAFT_KEY), data) ?? {
        date: nextThursdayISO(),
        organiserId: data.currentUserId,
        groups: [emptyGroup()],
      },
    [data]
  );

  const [date, setDate] = useState<string>(initial.date);
  const [organiserId, setOrganiserId] = useState<number>(initial.organiserId);
  const [groups, setGroups] = useState<GroupState[]>(initial.groups);
  const [activeGroup, setActiveGroup] = useState(0);
  const [query, setQuery] = useState("");
  const [errors, setErrors] = useState<string[]>([]);
  const [submitting, setSubmitting] = useState(false);

  const locationsById = useMemo(() => {
    const map = new Map<number, LocationOption>();
    data.locations.forEach((l) => map.set(l.id, l));
    return map;
  }, [data.locations]);

  const volunteersById = useMemo(() => {
    const map = new Map<number, Option>();
    data.volunteers.forEach((v) => map.set(v.id, v));
    return map;
  }, [data.volunteers]);

  // Autosave the in-progress trip so an accidental reload doesn't lose it.
  useEffect(() => {
    const draft: DraftState = { date, organiserId, groups };
    window.localStorage.setItem(DRAFT_KEY, JSON.stringify(draft));
  }, [date, organiserId, groups]);

  const assignedLocationIds = useMemo(() => {
    const set = new Set<number>();
    groups.forEach((g) => g.locationIds.forEach((id) => set.add(id)));
    return set;
  }, [groups]);

  const pool = useMemo(() => {
    const q = query.trim().toLowerCase();
    return data.locations.filter(
      (l) => !assignedLocationIds.has(l.id) && (q === "" || l.name.toLowerCase().includes(q))
    );
  }, [data.locations, assignedLocationIds, query]);

  const updateGroup = (index: number, patch: Partial<GroupState>) => {
    setGroups((prev) => prev.map((g, i) => (i === index ? { ...g, ...patch } : g)));
  };

  const assignLocation = (locationId: number) => {
    const target = groups[activeGroup] ? activeGroup : 0;
    updateGroup(target, { locationIds: [...groups[target].locationIds, locationId] });
  };

  const unassignLocation = (groupIndex: number, locationId: number) => {
    updateGroup(groupIndex, {
      locationIds: groups[groupIndex].locationIds.filter((id) => id !== locationId),
    });
  };

  const addMember = (groupIndex: number, volunteerId: number) => {
    updateGroup(groupIndex, { volunteerIds: [...groups[groupIndex].volunteerIds, volunteerId] });
  };

  const removeMember = (groupIndex: number, volunteerId: number) => {
    updateGroup(groupIndex, {
      volunteerIds: groups[groupIndex].volunteerIds.filter((id) => id !== volunteerId),
      driverIds: groups[groupIndex].driverIds.filter((id) => id !== volunteerId),
    });
  };

  const toggleDriver = (groupIndex: number, volunteerId: number) => {
    const drivers = groups[groupIndex].driverIds;
    updateGroup(groupIndex, {
      driverIds: drivers.includes(volunteerId)
        ? drivers.filter((id) => id !== volunteerId)
        : [...drivers, volunteerId],
    });
  };

  // A volunteer belongs to at most one group: hide those taken by other groups.
  const volunteersTakenElsewhere = (groupIndex: number): Set<number> => {
    const set = new Set<number>();
    groups.forEach((g, i) => {
      if (i !== groupIndex) g.volunteerIds.forEach((id) => set.add(id));
    });
    return set;
  };

  const addGroup = () => {
    setGroups((prev) => [...prev, emptyGroup()]);
    setActiveGroup(groups.length);
  };

  const removeGroup = (index: number) => {
    if (groups.length === 1) return;
    setGroups((prev) => prev.filter((_, i) => i !== index));
    setActiveGroup((prev) => Math.max(0, prev >= index ? prev - 1 : prev));
  };

  const reset = () => {
    window.localStorage.removeItem(DRAFT_KEY);
    setDate(nextThursdayISO());
    setOrganiserId(data.currentUserId);
    setGroups([emptyGroup()]);
    setActiveGroup(0);
    setErrors([]);
  };

  const groupTotals = (group: GroupState) =>
    group.locationIds.reduce(
      (acc, id) => {
        const loc = locationsById.get(id);
        return {
          people: acc.people + (loc?.person_count ?? 0),
          sandwiches: acc.sandwiches + (loc?.sandwich_count ?? 0),
        };
      },
      { people: 0, sandwiches: 0 }
    );

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
        window.localStorage.removeItem(DRAFT_KEY);
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
    <div>
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
        <div style={{ display: "flex", gap: "1.5rem", flexWrap: "wrap", alignItems: "flex-end" }}>
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
          <button
            type="button"
            className="btn btn-default"
            onClick={reset}
            style={{ marginLeft: "auto" }}
          >
            Wyczyść
          </button>
        </div>
      </section>

      <div style={{ display: "flex", gap: "1.25rem", alignItems: "flex-start", flexWrap: "wrap" }}>
        <aside id="location-pool" style={poolPanel}>
          <h4 style={{ marginTop: 0 }}>Nieprzypisane lokacje ({pool.length})</h4>
          <p style={{ color: "#888", fontSize: "0.85rem", margin: "0 0 0.5rem" }}>
            Klikasz → Grupa {activeGroup + 1}
          </p>
          <input
            type="text"
            className="form-control"
            placeholder="Szukaj lokacji…"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            style={{ marginBottom: "0.5rem" }}
          />
          <div style={poolList}>
            {pool.map((l) => (
              <button
                key={l.id}
                type="button"
                style={poolItem}
                onClick={() => assignLocation(l.id)}
              >
                <span style={{ flex: 1, textAlign: "left" }}>{l.name}</span>
                <span style={{ color: "#666", fontSize: "0.8rem" }}>{l.person_count} os.</span>
                <RecencyBadge rank={l.recent_rank} />
              </button>
            ))}
            {pool.length === 0 && (
              <div style={{ padding: "0.6rem", color: "#999" }}>
                {query ? "Brak wyników" : "Wszystko przypisane"}
              </div>
            )}
          </div>
        </aside>

        <div style={{ flex: 1, minWidth: 320 }}>
          {groups.map((group, index) => {
            const color = PALETTE[index % PALETTE.length];
            const isActive = index === activeGroup;
            const totals = groupTotals(group);
            return (
              <section
                key={index}
                style={{
                  ...card,
                  borderLeft: `4px solid ${color}`,
                  outline: isActive ? `2px solid ${color}` : "none",
                }}
              >
                <div
                  style={{
                    display: "flex",
                    justifyContent: "space-between",
                    alignItems: "center",
                    cursor: "pointer",
                  }}
                  onClick={() => setActiveGroup(index)}
                >
                  <h3 style={{ ...heading, color, marginBottom: 0 }}>
                    Grupa {index + 1}
                    {isActive && <span style={activeTag}>aktywna</span>}
                  </h3>
                  {groups.length > 1 && (
                    <button
                      type="button"
                      className="btn btn-sm btn-danger"
                      onClick={(e) => {
                        e.stopPropagation();
                        removeGroup(index);
                      }}
                    >
                      Usuń grupę
                    </button>
                  )}
                </div>

                <p style={{ color: "#555", margin: "0.5rem 0 0.75rem" }}>
                  Σ {totals.people} os · {totals.sandwiches} kanapek
                </p>

                {group.locationIds.length === 0 ? (
                  <p style={{ color: "#999", margin: "0 0 0.75rem" }}>
                    Brak lokacji — kliknij lokację z puli po lewej.
                  </p>
                ) : (
                  <ol style={destList}>
                    {group.locationIds.map((id) => (
                      <li key={id} style={destItem}>
                        <span style={{ flex: 1 }}>{locationsById.get(id)?.name ?? id}</span>
                        <span style={{ color: "#888", fontSize: "0.8rem" }}>
                          {locationsById.get(id)?.person_count ?? 0} os.
                        </span>
                        <button
                          type="button"
                          style={removeChip}
                          title="Usuń z grupy"
                          onClick={() => unassignLocation(index, id)}
                        >
                          ✕
                        </button>
                      </li>
                    ))}
                  </ol>
                )}

                <VolunteerPicker
                  volunteers={data.volunteers}
                  volunteersById={volunteersById}
                  memberIds={group.volunteerIds}
                  driverIds={group.driverIds}
                  takenElsewhere={volunteersTakenElsewhere(index)}
                  onAdd={(id) => addMember(index, id)}
                  onRemove={(id) => removeMember(index, id)}
                  onToggleDriver={(id) => toggleDriver(index, id)}
                />
              </section>
            );
          })}

          <button
            type="button"
            className="btn btn-secondary"
            onClick={addGroup}
            style={{ marginBottom: "1.25rem" }}
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
      </div>
    </div>
  );
}

function RecencyBadge({ rank }: { rank: number | null }) {
  if (rank === 0) return <span style={{ ...badge, background: "#27ae60" }}>ostatni</span>;
  if (rank === 1) return <span style={{ ...badge, background: "#f39c12" }}>2 temu</span>;
  return null;
}

// One searchable list to add volunteers to the group; members appear as chips,
// each with a driver toggle. Volunteers already in another group are excluded
// (a volunteer belongs to one group).
function VolunteerPicker({
  volunteers,
  volunteersById,
  memberIds,
  driverIds,
  takenElsewhere,
  onAdd,
  onRemove,
  onToggleDriver,
}: {
  volunteers: Option[];
  volunteersById: Map<number, Option>;
  memberIds: number[];
  driverIds: number[];
  takenElsewhere: Set<number>;
  onAdd: (id: number) => void;
  onRemove: (id: number) => void;
  onToggleDriver: (id: number) => void;
}) {
  const [query, setQuery] = useState("");
  const available = useMemo(() => {
    const q = query.trim().toLowerCase();
    return volunteers.filter(
      (v) =>
        !memberIds.includes(v.id) &&
        !takenElsewhere.has(v.id) &&
        (q === "" || v.name.toLowerCase().includes(q))
    );
  }, [volunteers, memberIds, takenElsewhere, query]);

  return (
    <div>
      <strong>Wolontariusze</strong>
      {memberIds.length > 0 && (
        <div style={{ display: "flex", flexWrap: "wrap", gap: "0.4rem", margin: "0.5rem 0" }}>
          {memberIds.map((id) => {
            const isDriver = driverIds.includes(id);
            const name = volunteersById.get(id)?.name ?? String(id);
            return (
              <span key={id} style={isDriver ? driverChip : memberChip}>
                <button
                  type="button"
                  aria-label={`Kierowca: ${name}`}
                  title={isDriver ? "Kierowca — kliknij, by cofnąć" : "Oznacz jako kierowcę"}
                  onClick={() => onToggleDriver(id)}
                  style={driverToggle}
                >
                  🚗
                </button>
                <span>
                  {name}
                  {isDriver && " (kierowca)"}
                </span>
                <button
                  type="button"
                  aria-label={`Usuń: ${name}`}
                  onClick={() => onRemove(id)}
                  style={removeChip}
                >
                  ✕
                </button>
              </span>
            );
          })}
        </div>
      )}
      <input
        type="text"
        className="form-control"
        placeholder="Dodaj wolontariusza…"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        style={{ margin: "0.25rem 0 0.5rem" }}
      />
      <div style={{ ...listBox, maxHeight: 150 }}>
        {available.map((v) => (
          <button key={v.id} type="button" style={addItem} onClick={() => onAdd(v.id)}>
            {v.name}
          </button>
        ))}
        {available.length === 0 && (
          <div style={{ padding: "0.5rem", color: "#999" }}>Brak dostępnych</div>
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

const poolPanel: React.CSSProperties = {
  ...card,
  width: 320,
  position: "sticky",
  top: "1rem",
  alignSelf: "flex-start",
};

const poolList: React.CSSProperties = {
  border: "1px solid #ddd",
  borderRadius: 4,
  maxHeight: "60vh",
  overflowY: "auto",
};

const poolItem: React.CSSProperties = {
  display: "flex",
  alignItems: "center",
  gap: "0.5rem",
  width: "100%",
  padding: "0.45rem 0.6rem",
  border: "none",
  borderBottom: "1px solid #f0f0f0",
  background: "transparent",
  cursor: "pointer",
};

const destList: React.CSSProperties = {
  listStyle: "decimal",
  paddingLeft: "1.4rem",
  margin: "0 0 0.75rem",
};

const destItem: React.CSSProperties = {
  display: "flex",
  alignItems: "center",
  gap: "0.5rem",
  padding: "0.2rem 0",
};

const listBox: React.CSSProperties = {
  border: "1px solid #ddd",
  borderRadius: 4,
  overflowY: "auto",
};

const addItem: React.CSSProperties = {
  display: "block",
  width: "100%",
  textAlign: "left",
  padding: "0.35rem 0.6rem",
  border: "none",
  borderBottom: "1px solid #f0f0f0",
  background: "transparent",
  cursor: "pointer",
};

const memberChip: React.CSSProperties = {
  display: "inline-flex",
  alignItems: "center",
  gap: "0.3rem",
  background: "#f2f2f2",
  border: "1px solid #ddd",
  borderRadius: 14,
  padding: "0.15rem 0.5rem",
  fontSize: "0.85rem",
};

const driverChip: React.CSSProperties = {
  ...memberChip,
  background: "#fdf0d5",
  border: "1px solid #e0b96b",
  fontWeight: 600,
};

const driverToggle: React.CSSProperties = {
  border: "none",
  background: "transparent",
  cursor: "pointer",
  padding: 0,
  fontSize: "0.85rem",
  lineHeight: 1,
};

const removeChip: React.CSSProperties = {
  border: "none",
  background: "transparent",
  color: "#c0392b",
  cursor: "pointer",
  fontSize: "0.9rem",
};

const badge: React.CSSProperties = {
  color: "#fff",
  borderRadius: 10,
  padding: "0.1rem 0.45rem",
  fontSize: "0.7rem",
  whiteSpace: "nowrap",
};

const activeTag: React.CSSProperties = {
  marginLeft: "0.6rem",
  fontSize: "0.7rem",
  fontWeight: "normal",
  background: "#eef4fb",
  color: "#2c6cb0",
  borderRadius: 10,
  padding: "0.1rem 0.5rem",
};
