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
  const [volunteerQuery, setVolunteerQuery] = useState("");
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

  const assignedVolunteerIds = useMemo(() => {
    const set = new Set<number>();
    groups.forEach((g) => g.volunteerIds.forEach((id) => set.add(id)));
    return set;
  }, [groups]);

  const volunteerPool = useMemo(() => {
    const q = volunteerQuery.trim().toLowerCase();
    return data.volunteers.filter(
      (v) => !assignedVolunteerIds.has(v.id) && (q === "" || v.name.toLowerCase().includes(q))
    );
  }, [data.volunteers, assignedVolunteerIds, volunteerQuery]);

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

  const groupPeople = (group: GroupState) =>
    group.locationIds.reduce((sum, id) => sum + (locationsById.get(id)?.person_count ?? 0), 0);

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
    <div style={{ padding: "1.5rem" }}>
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
        <div style={{ width: 384, display: "flex", flexDirection: "column", gap: "1.25rem" }}>
          <aside id="location-pool" style={poolPanel}>
            <h4 style={{ marginTop: 0 }}>Miejsca</h4>
            <input
              type="text"
              className="form-control"
              placeholder="Szukaj miejsca…"
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

          <aside style={poolPanel}>
            <h4 style={{ marginTop: 0 }}>Wolontariusze</h4>
            <input
              type="text"
              className="form-control"
              placeholder="Szukaj wolontariusza…"
              value={volunteerQuery}
              onChange={(e) => setVolunteerQuery(e.target.value)}
              style={{ marginBottom: "0.5rem" }}
            />
            <div style={poolList}>
              {volunteerPool.map((v) => (
                <button
                  key={v.id}
                  type="button"
                  style={poolItem}
                  onClick={() => addMember(activeGroup, v.id)}
                >
                  <span aria-hidden="true">{personIcon(v.gender)}</span>
                  <span style={{ flex: 1, textAlign: "left" }}>{v.name}</span>
                </button>
              ))}
              {volunteerPool.length === 0 && (
                <div style={{ padding: "0.6rem", color: "#999" }}>
                  {volunteerQuery ? "Brak wyników" : "Wszyscy przypisani"}
                </div>
              )}
            </div>
          </aside>
        </div>

        <div style={{ flex: 1, minWidth: 320 }}>
          {groups.map((group, index) => {
            const color = PALETTE[index % PALETTE.length];
            const isActive = index === activeGroup;
            const peopleTotal = groupPeople(group);
            return (
              <section
                key={index}
                onClick={() => setActiveGroup(index)}
                style={{
                  ...card,
                  maxWidth: 760,
                  cursor: "pointer",
                  borderLeft: `4px solid ${isActive ? color : "#d5d5d5"}`,
                  outline: isActive ? `2px solid ${color}` : "none",
                }}
              >
                <div
                  style={{
                    display: "flex",
                    justifyContent: "space-between",
                    alignItems: "center",
                  }}
                >
                  <h3 style={{ ...heading, color: isActive ? color : "#aaa", marginBottom: 0 }}>
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
                  Σ {peopleTotal} os
                </p>

                <strong>Miejsca</strong>
                {group.locationIds.length === 0 ? (
                  <p style={{ color: "#999", margin: "0.25rem 0 0.75rem" }}>
                    Brak miejsc — kliknij lokację z puli po lewej.
                  </p>
                ) : (
                  <div
                    style={{
                      display: "flex",
                      flexWrap: "wrap",
                      gap: "0.6rem",
                      margin: "0.5rem 0 0.75rem",
                    }}
                  >
                    {group.locationIds.map((id) => {
                      const loc = locationsById.get(id);
                      return (
                        <div key={id} style={locationCard}>
                          <div
                            style={{
                              display: "flex",
                              justifyContent: "space-between",
                              alignItems: "flex-start",
                              gap: "0.5rem",
                            }}
                          >
                            <strong>{loc?.name ?? id}</strong>
                            <button
                              type="button"
                              style={removeChip}
                              title="Usuń z grupy"
                              aria-label={`Usuń lokację: ${loc?.name ?? id}`}
                              onClick={() => unassignLocation(index, id)}
                            >
                              ✕
                            </button>
                          </div>
                          <div style={{ color: "#888", fontSize: "0.75rem" }}>
                            {locationTypeLabel(loc?.location_type)}
                          </div>
                          {loc && (loc.people.length > 0 || loc.person_count > 0) && (
                            <div
                              style={{ color: "#555", fontSize: "0.8rem", marginTop: "0.25rem" }}
                            >
                              👤{" "}
                              {loc.people.length > 0
                                ? loc.people.map((p) => p.name).join(", ")
                                : loc.person_count}
                            </div>
                          )}
                          {loc && loc.animals.length > 0 && (
                            <div
                              style={{ color: "#555", fontSize: "0.8rem", marginTop: "0.15rem" }}
                            >
                              🐾{" "}
                              {loc.animals
                                .map((a) => `${a.name} (${speciesLabel(a.species)})`)
                                .join(", ")}
                            </div>
                          )}
                        </div>
                      );
                    })}
                  </div>
                )}

                <strong>Wolontariusze</strong>
                <MemberChips
                  memberIds={group.volunteerIds}
                  driverIds={group.driverIds}
                  volunteersById={volunteersById}
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

// Members assigned to a group, shown as chips. Add/remove happens from the
// shared volunteer pool on the left; here each chip just toggles driver or
// removes the member. The greyed/coloured car marks the driver.
function MemberChips({
  memberIds,
  driverIds,
  volunteersById,
  onRemove,
  onToggleDriver,
}: {
  memberIds: number[];
  driverIds: number[];
  volunteersById: Map<number, Option>;
  onRemove: (id: number) => void;
  onToggleDriver: (id: number) => void;
}) {
  if (memberIds.length === 0) {
    return (
      <p style={{ color: "#999", margin: "0.25rem 0 0" }}>
        Brak wolontariuszy — wybierz z puli po lewej.
      </p>
    );
  }

  return (
    <div style={{ display: "flex", flexWrap: "wrap", gap: "0.4rem", margin: "0.5rem 0 0" }}>
      {memberIds.map((id) => {
        const isDriver = driverIds.includes(id);
        const volunteer = volunteersById.get(id);
        const name = volunteer?.name ?? String(id);
        return (
          <span key={id} style={memberChip}>
            <span aria-hidden="true">{personIcon(volunteer?.gender)}</span>
            <span>{name}</span>
            <button
              type="button"
              aria-label={`Kierowca: ${name}`}
              title={isDriver ? "Kierowca — kliknij, by cofnąć" : "Oznacz jako kierowcę"}
              onClick={() => onToggleDriver(id)}
              style={{
                ...driverToggle,
                filter: isDriver ? "none" : "grayscale(1)",
                opacity: isDriver ? 1 : 0.4,
              }}
            >
              🚗
            </button>
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
  );
}

function locationTypeLabel(type?: string): string {
  if (type === "estimated") return "Grupowe";
  if (type === "regular") return "Zwykłe";
  return "";
}

function speciesLabel(species: string): string {
  return (
    { cat: "kot", dog: "pies", rat: "szczur", bird: "ptak", other: "inny" }[species] ?? species
  );
}

function personIcon(gender?: string | null): string {
  if (gender === "female") return "👩";
  if (gender === "male") return "👨";
  if (gender === "non_binary") return "🧑";
  return "👤"; // gender not set
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
  width: "100%",
  marginBottom: 0,
};

const poolList: React.CSSProperties = {
  border: "1px solid #ddd",
  borderRadius: 4,
  maxHeight: 220, // ~6 rows
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

const locationCard: React.CSSProperties = {
  border: "1px solid #e0e0e0",
  borderRadius: 6,
  padding: "0.5rem 0.6rem",
  width: 200,
  background: "#fafafa",
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
