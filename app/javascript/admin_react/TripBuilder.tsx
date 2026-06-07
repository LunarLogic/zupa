import { useEffect, useMemo, useState } from "react";

import type { Bootstrap, ExistingTrip, LocationOption, Option } from "./types";

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

// v4: 3-step wizard. preselectedLocationIds (step 1), roster + rosterDriverIds
// (step 2), groups place those into trip groups (step 3).
const DRAFT_KEY = "zupa.tripBuilder.v4";

const STEPS = ["Miejsca", "Wolontariusze", "Grupy"];

interface WizardGroup {
  locationIds: number[];
  volunteerIds: number[];
  notes: Record<string, string>; // location id → additional info
  groupNote: string; // additional info for the whole group
}

interface DraftState {
  date: string;
  organiserId: number;
  step: number;
  preselectedLocationIds: number[];
  roster: number[];
  rosterDriverIds: number[];
  groups: WizardGroup[];
}

function nextThursdayISO(): string {
  const today = new Date();
  const daysAhead = (4 - today.getDay() + 7) % 7 || 7; // 4 = Thursday
  const target = new Date(today);
  target.setDate(today.getDate() + daysAhead);
  return target.toISOString().slice(0, 10);
}

function defaultDraft(data: Bootstrap): DraftState {
  return {
    date: nextThursdayISO(),
    organiserId: data.currentUserId,
    step: 1,
    preselectedLocationIds: [],
    roster: [],
    rosterDriverIds: [],
    groups: [{ locationIds: [], volunteerIds: [], notes: {}, groupNote: "" }],
  };
}

// Restore a persisted draft, dropping ids that no longer exist in the bootstrap.
function sanitizeDraft(raw: string | null, data: Bootstrap): DraftState | null {
  if (!raw) return null;
  try {
    const parsed = JSON.parse(raw) as Partial<DraftState>;
    const locationIds = new Set(data.locations.map((l) => l.id));
    const volunteerIds = new Set(data.volunteers.map((v) => v.id));
    const organiserIds = new Set(data.adminUsers.map((u) => u.id));

    const preselected = (parsed.preselectedLocationIds || []).filter((id) => locationIds.has(id));
    const roster = (parsed.roster || []).filter((id) => volunteerIds.has(id));
    const rosterDriverIds = (parsed.rosterDriverIds || []).filter((id) => roster.includes(id));
    const groups = (parsed.groups || []).map((g) => {
      const locationIds = (g.locationIds || []).filter((id) => preselected.includes(id));
      const notes: Record<string, string> = {};
      locationIds.forEach((id) => {
        const note = g.notes?.[id];
        if (note) notes[id] = note;
      });
      return {
        locationIds,
        volunteerIds: (g.volunteerIds || []).filter((id) => roster.includes(id)),
        notes,
        groupNote: g.groupNote ?? "",
      };
    });

    return {
      date: parsed.date || nextThursdayISO(),
      organiserId: organiserIds.has(parsed.organiserId as number)
        ? (parsed.organiserId as number)
        : data.currentUserId,
      step: [1, 2, 3].includes(parsed.step as number) ? (parsed.step as number) : 1,
      preselectedLocationIds: preselected,
      roster,
      rosterDriverIds,
      groups:
        groups.length > 0
          ? groups
          : [{ locationIds: [], volunteerIds: [], notes: {}, groupNote: "" }],
    };
  } catch {
    return null;
  }
}

function overdueFirst(a: LocationOption, b: LocationOption): number {
  if (a.last_scheduled_at !== b.last_scheduled_at) {
    if (a.last_scheduled_at == null) return -1;
    if (b.last_scheduled_at == null) return 1;
    return a.last_scheduled_at < b.last_scheduled_at ? -1 : 1;
  }
  return a.name.localeCompare(b.name);
}

function editDraft(e: ExistingTrip, currentUserId: number): DraftState {
  return {
    date: e.date ?? nextThursdayISO(),
    organiserId: e.organiserId ?? currentUserId,
    step: 3,
    preselectedLocationIds: e.preselectedLocationIds,
    roster: e.roster,
    rosterDriverIds: e.rosterDriverIds,
    groups:
      e.groups.length > 0
        ? e.groups.map((g) => ({
            locationIds: g.locationIds,
            volunteerIds: g.volunteerIds,
            notes: g.notes ?? {},
            groupNote: g.groupNote ?? "",
          }))
        : [{ locationIds: [], volunteerIds: [], notes: {}, groupNote: "" }],
  };
}

export default function TripBuilder({ data }: { data: Bootstrap }) {
  const editing = data.existingTrip != null;

  const initial = useMemo(
    () =>
      data.existingTrip
        ? editDraft(data.existingTrip, data.currentUserId)
        : sanitizeDraft(window.localStorage.getItem(DRAFT_KEY), data) ?? defaultDraft(data),
    [data]
  );

  const [step, setStep] = useState(initial.step);
  const [date, setDate] = useState(initial.date);
  const [organiserId, setOrganiserId] = useState(initial.organiserId);
  const [preselectedLocationIds, setPreselected] = useState<number[]>(
    initial.preselectedLocationIds
  );
  const [roster, setRoster] = useState<number[]>(initial.roster);
  const [rosterDriverIds, setRosterDriverIds] = useState<number[]>(initial.rosterDriverIds);
  const [groups, setGroups] = useState<WizardGroup[]>(initial.groups);
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

  useEffect(() => {
    if (editing) return; // edit mode always reflects the server trip; no draft
    const draft: DraftState = {
      date,
      organiserId,
      step,
      preselectedLocationIds,
      roster,
      rosterDriverIds,
      groups,
    };
    window.localStorage.setItem(DRAFT_KEY, JSON.stringify(draft));
  }, [editing, date, organiserId, step, preselectedLocationIds, roster, rosterDriverIds, groups]);

  const reset = () => {
    const d = data.existingTrip
      ? editDraft(data.existingTrip, data.currentUserId)
      : defaultDraft(data);
    if (!editing) window.localStorage.removeItem(DRAFT_KEY);
    setStep(d.step);
    setDate(d.date);
    setOrganiserId(d.organiserId);
    setPreselected(d.preselectedLocationIds);
    setRoster(d.roster);
    setRosterDriverIds(d.rosterDriverIds);
    setGroups(d.groups);
    setErrors([]);
  };

  const removeFromRoster = (id: number) => {
    setRoster((prev) => prev.filter((x) => x !== id));
    setRosterDriverIds((prev) => prev.filter((x) => x !== id));
    setGroups((prev) =>
      prev.map((g) => ({ ...g, volunteerIds: g.volunteerIds.filter((x) => x !== id) }))
    );
  };

  const removeFromPreselected = (id: number) => {
    setPreselected((prev) => prev.filter((x) => x !== id));
    setGroups((prev) =>
      prev.map((g) => ({ ...g, locationIds: g.locationIds.filter((x) => x !== id) }))
    );
  };

  const canAdvance = step !== 1 || preselectedLocationIds.length > 0;
  const canSubmit = groups.some((g) => g.locationIds.length > 0);

  const submit = async () => {
    setSubmitting(true);
    setErrors([]);
    try {
      const response = await fetch(editing ? (data.updateUrl as string) : data.createUrl, {
        method: editing ? "PATCH" : "POST",
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
              volunteer_ids: g.volunteerIds,
              driver_ids: g.volunteerIds.filter((id) => rosterDriverIds.includes(id)),
              additional_info: g.notes,
              group_additional_info: g.groupNote,
            })),
        }),
      });

      const payload = await response.json();
      if (response.ok && payload.redirect_to) {
        if (!editing) window.localStorage.removeItem(DRAFT_KEY);
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

      {/* Pinned general-data box */}
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

      <StepBar step={step} onBack={() => setStep((s) => Math.max(1, s - 1))} />

      {step === 1 && (
        <Step1Locations
          data={data}
          locationsById={locationsById}
          preselected={preselectedLocationIds}
          onAdd={(id) => setPreselected((prev) => [...prev, id])}
          onRemove={removeFromPreselected}
          onCopyRotation={() =>
            setPreselected(data.rotationLocationIds.filter((id) => locationsById.has(id)))
          }
        />
      )}

      {step === 2 && (
        <Step2Volunteers
          data={data}
          volunteersById={volunteersById}
          roster={roster}
          rosterDriverIds={rosterDriverIds}
          onAdd={(id) => setRoster((prev) => [...prev, id])}
          onRemove={removeFromRoster}
          onToggleDriver={(id) =>
            setRosterDriverIds((prev) =>
              prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id]
            )
          }
        />
      )}

      {step === 3 && (
        <Step3Groups
          locationsById={locationsById}
          volunteersById={volunteersById}
          preselected={preselectedLocationIds}
          roster={roster}
          rosterDriverIds={rosterDriverIds}
          groups={groups}
          setGroups={setGroups}
        />
      )}

      {/* Wizard navigation */}
      <div style={{ display: "flex", gap: "0.75rem", marginTop: "1.5rem" }}>
        {step > 1 && (
          <button type="button" className="btn btn-default" onClick={() => setStep(step - 1)}>
            ← Wstecz
          </button>
        )}
        {step < 3 && (
          <button
            type="button"
            className="btn btn-primary"
            disabled={!canAdvance}
            onClick={() => setStep(step + 1)}
          >
            Dalej →
          </button>
        )}
        {step === 3 && (
          <button
            type="button"
            className="btn btn-success btn-lg"
            disabled={!canSubmit || submitting}
            onClick={submit}
          >
            {submitting ? "Zapisuję…" : editing ? "Zapisz zmiany" : "Utwórz wyjazd"}
          </button>
        )}
      </div>
    </div>
  );
}

function StepBar({ step, onBack }: { step: number; onBack: () => void }) {
  return (
    <div style={{ display: "flex", gap: "0.5rem", margin: "0 0 1.25rem" }}>
      {STEPS.map((label, i) => {
        const n = i + 1;
        const active = n === step;
        const done = n < step;
        const clickable = n === step - 1; // only one step back
        return (
          <div
            key={n}
            role={clickable ? "button" : undefined}
            onClick={clickable ? onBack : undefined}
            title={clickable ? "Wstecz" : undefined}
            style={{
              flex: 1,
              padding: "0.5rem 0.75rem",
              borderRadius: 6,
              cursor: clickable ? "pointer" : "default",
              fontWeight: active ? 600 : 400,
              color: active ? "#fff" : done ? "#2c6cb0" : "#888",
              background: active ? "#4d6bb2" : done ? "#eef4fb" : "#f2f2f2",
              borderBottom: active ? "3px solid #2c4a86" : "3px solid transparent",
            }}
          >
            {n}. {label}
          </div>
        );
      })}
    </div>
  );
}

function Step1Locations({
  data,
  locationsById,
  preselected,
  onAdd,
  onRemove,
  onCopyRotation,
}: {
  data: Bootstrap;
  locationsById: Map<number, LocationOption>;
  preselected: number[];
  onAdd: (id: number) => void;
  onRemove: (id: number) => void;
  onCopyRotation: () => void;
}) {
  const [query, setQuery] = useState("");
  const [hideRecent, setHideRecent] = useState(false);

  const candidates = useMemo(() => {
    const q = query.trim().toLowerCase();
    return data.locations
      .filter(
        (l) =>
          !preselected.includes(l.id) &&
          (q === "" || l.name.toLowerCase().includes(q)) &&
          (!hideRecent || l.recent_rank !== 0)
      )
      .sort(overdueFirst);
  }, [data.locations, preselected, query, hideRecent]);

  return (
    <div id="location-pool">
      <div
        style={{
          display: "flex",
          gap: "1rem",
          flexWrap: "wrap",
          alignItems: "center",
          marginBottom: "1rem",
        }}
      >
        <input
          type="text"
          className="form-control"
          placeholder="Szukaj miejsca…"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          style={{ maxWidth: 280 }}
        />
        <label style={{ ...checkboxRow, margin: 0 }}>
          <input
            type="checkbox"
            checked={hideRecent}
            onChange={(e) => setHideRecent(e.target.checked)}
          />
          Ukryj odwiedzone na ostatnim wyjeździe
        </label>
        {data.rotationLocationIds.length > 0 && (
          <button type="button" className="btn btn-default btn-sm" onClick={onCopyRotation}>
            Kopiuj z wyjazdu sprzed 2 tyg.
            {data.rotationTripDate ? ` (${data.rotationTripDate})` : ""}
          </button>
        )}
      </div>

      <h4 style={{ marginTop: 0 }}>Wybrane ({preselected.length})</h4>
      {preselected.length === 0 ? (
        <p style={{ color: "#999" }}>Kliknij miejsce poniżej, aby je dodać do wyjazdu.</p>
      ) : (
        <div style={cardGrid}>
          {preselected.map((id) => (
            <LocationCard
              key={id}
              loc={locationsById.get(id)}
              selected
              onRemove={() => onRemove(id)}
            />
          ))}
        </div>
      )}

      <h4 style={{ marginTop: "1.5rem" }}>Do wyboru ({candidates.length})</h4>
      {candidates.length === 0 ? (
        <p style={{ color: "#999" }}>Brak miejsc.</p>
      ) : (
        <div style={cardGrid}>
          {candidates.map((l) => (
            <LocationCard key={l.id} loc={l} onClick={() => onAdd(l.id)} />
          ))}
        </div>
      )}
    </div>
  );
}

function Step2Volunteers({
  data,
  volunteersById,
  roster,
  rosterDriverIds,
  onAdd,
  onRemove,
  onToggleDriver,
}: {
  data: Bootstrap;
  volunteersById: Map<number, Option>;
  roster: number[];
  rosterDriverIds: number[];
  onAdd: (id: number) => void;
  onRemove: (id: number) => void;
  onToggleDriver: (id: number) => void;
}) {
  const [query, setQuery] = useState("");

  const candidates = useMemo(() => {
    const q = query.trim().toLowerCase();
    return data.volunteers
      .filter((v) => !roster.includes(v.id) && (q === "" || v.name.toLowerCase().includes(q)))
      .sort((a, b) => {
        const ar = a.on_recent_trips ? 0 : 1;
        const br = b.on_recent_trips ? 0 : 1;
        return ar !== br ? ar - br : a.name.localeCompare(b.name);
      });
  }, [data.volunteers, roster, query]);

  return (
    <div style={{ display: "flex", gap: "1.25rem", alignItems: "flex-start", flexWrap: "wrap" }}>
      <aside style={{ ...poolPanel, width: 384 }}>
        <h4 style={{ marginTop: 0 }}>Dodaj wolontariuszy</h4>
        <input
          type="text"
          className="form-control"
          placeholder="Szukaj wolontariusza…"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          style={{ marginBottom: "0.5rem" }}
        />
        <div style={poolList}>
          {candidates.map((v) => (
            <button key={v.id} type="button" style={poolItem} onClick={() => onAdd(v.id)}>
              <span aria-hidden="true">{personIcon(v.gender)}</span>
              <span style={{ flex: 1, textAlign: "left" }}>{v.name}</span>
              {v.on_recent_trips && (
                <span style={{ ...badge, background: "#27ae60" }}>ostatnio</span>
              )}
            </button>
          ))}
          {candidates.length === 0 && (
            <div style={{ padding: "0.6rem", color: "#999" }}>Brak wolontariuszy</div>
          )}
        </div>
      </aside>

      <div style={{ flex: 1, minWidth: 320 }}>
        <h4 style={{ marginTop: 0 }}>Skład wyjazdu ({roster.length})</h4>
        <p style={{ color: "#888", fontSize: "0.85rem", marginTop: 0 }}>
          Kliknij 🚗, aby oznaczyć kierowcę.
        </p>
        {roster.length === 0 ? (
          <p style={{ color: "#999" }}>Dodaj wolontariuszy z listy po lewej.</p>
        ) : (
          <div style={{ display: "flex", flexWrap: "wrap", gap: "0.4rem" }}>
            {roster.map((id) => (
              <MemberChip
                key={id}
                volunteer={volunteersById.get(id)}
                isDriver={rosterDriverIds.includes(id)}
                onToggleDriver={() => onToggleDriver(id)}
                onRemove={() => onRemove(id)}
              />
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

function Step3Groups({
  locationsById,
  volunteersById,
  preselected,
  roster,
  rosterDriverIds,
  groups,
  setGroups,
}: {
  locationsById: Map<number, LocationOption>;
  volunteersById: Map<number, Option>;
  preselected: number[];
  roster: number[];
  rosterDriverIds: number[];
  groups: WizardGroup[];
  setGroups: React.Dispatch<React.SetStateAction<WizardGroup[]>>;
}) {
  const [activeGroup, setActiveGroup] = useState(0);
  const [locationQuery, setLocationQuery] = useState("");
  const [volunteerQuery, setVolunteerQuery] = useState("");

  const assignedLocationIds = useMemo(
    () => new Set(groups.flatMap((g) => g.locationIds)),
    [groups]
  );
  const assignedVolunteerIds = useMemo(
    () => new Set(groups.flatMap((g) => g.volunteerIds)),
    [groups]
  );

  const locationPool = useMemo(() => {
    const q = locationQuery.trim().toLowerCase();
    return preselected
      .filter((id) => !assignedLocationIds.has(id))
      .map((id) => locationsById.get(id))
      .filter((l): l is LocationOption => !!l && (q === "" || l.name.toLowerCase().includes(q)))
      .sort(overdueFirst);
  }, [preselected, assignedLocationIds, locationsById, locationQuery]);

  const volunteerPool = useMemo(() => {
    const q = volunteerQuery.trim().toLowerCase();
    return roster
      .filter((id) => !assignedVolunteerIds.has(id))
      .filter((id) => q === "" || (volunteersById.get(id)?.name ?? "").toLowerCase().includes(q));
  }, [roster, assignedVolunteerIds, volunteersById, volunteerQuery]);

  const updateGroup = (index: number, patch: Partial<WizardGroup>) =>
    setGroups((prev) => prev.map((g, i) => (i === index ? { ...g, ...patch } : g)));

  const targetGroup = groups[activeGroup] ? activeGroup : 0;

  return (
    <div style={{ display: "flex", gap: "1.25rem", alignItems: "flex-start", flexWrap: "wrap" }}>
      <div style={{ width: 384, display: "flex", flexDirection: "column", gap: "1.25rem" }}>
        <aside id="location-pool" style={poolPanel}>
          <h4 style={{ marginTop: 0 }}>Miejsca</h4>
          <input
            type="text"
            className="form-control"
            placeholder="Szukaj miejsca…"
            value={locationQuery}
            onChange={(e) => setLocationQuery(e.target.value)}
            style={{ marginBottom: "0.5rem" }}
          />
          <div style={poolList}>
            {locationPool.map((l) => (
              <button
                key={l.id}
                type="button"
                style={poolItem}
                onClick={() =>
                  updateGroup(targetGroup, {
                    locationIds: [...groups[targetGroup].locationIds, l.id],
                  })
                }
              >
                <span style={{ flex: 1, textAlign: "left" }}>{l.name}</span>
                <span style={{ color: "#666", fontSize: "0.8rem" }}>
                  {l.person_count} {peopleWord(l.person_count)}
                </span>
                <RecencyBadge rank={l.recent_rank} />
              </button>
            ))}
            {locationPool.length === 0 && (
              <div style={{ padding: "0.6rem", color: "#999" }}>Wszystko przypisane</div>
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
            {volunteerPool.map((id) => {
              const v = volunteersById.get(id);
              return (
                <button
                  key={id}
                  type="button"
                  style={poolItem}
                  onClick={() =>
                    updateGroup(targetGroup, {
                      volunteerIds: [...groups[targetGroup].volunteerIds, id],
                    })
                  }
                >
                  <span aria-hidden="true">{personIcon(v?.gender)}</span>
                  <span style={{ flex: 1, textAlign: "left" }}>{v?.name ?? id}</span>
                  {rosterDriverIds.includes(id) && <span aria-hidden="true">🚗</span>}
                </button>
              );
            })}
            {volunteerPool.length === 0 && (
              <div style={{ padding: "0.6rem", color: "#999" }}>Wszyscy przypisani</div>
            )}
          </div>
        </aside>
      </div>

      <div style={{ flex: 1, minWidth: 320 }}>
        {groups.map((group, index) => {
          const color = PALETTE[index % PALETTE.length];
          const isActive = index === activeGroup;
          const peopleTotal = group.locationIds.reduce(
            (sum, id) => sum + (locationsById.get(id)?.person_count ?? 0),
            0
          );
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
                style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}
              >
                <h3 style={{ ...heading, color: isActive ? color : "#aaa", marginBottom: 0 }}>
                  Grupa {index + 1}
                  <span
                    style={{
                      marginLeft: "0.6rem",
                      fontSize: "0.85rem",
                      fontWeight: "normal",
                      color: "#666",
                    }}
                  >
                    👤 {peopleTotal} {peopleWord(peopleTotal)}
                  </span>
                </h3>
                {groups.length > 1 && (
                  <button
                    type="button"
                    title="Usuń grupę"
                    aria-label={`Usuń grupę ${index + 1}`}
                    style={removeChip}
                    onClick={(e) => {
                      e.stopPropagation();
                      if (!window.confirm("Usunąć grupę?")) return;
                      setGroups((prev) => prev.filter((_, i) => i !== index));
                      setActiveGroup((prev) => Math.max(0, prev >= index ? prev - 1 : prev));
                    }}
                  >
                    ✕
                  </button>
                )}
              </div>

              <strong style={{ display: "block", marginTop: "1.15rem" }}>Miejsca</strong>
              {group.locationIds.length === 0 ? (
                <p style={{ color: "#999", margin: "0.25rem 0 0.75rem" }}>
                  Brak miejsc — kliknij miejsce z puli po lewej.
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
                  {group.locationIds.map((id) => (
                    <LocationCard
                      key={id}
                      loc={locationsById.get(id)}
                      note={group.notes[id] ?? ""}
                      onNoteChange={(value) =>
                        updateGroup(index, { notes: { ...group.notes, [id]: value } })
                      }
                      onRemove={() =>
                        updateGroup(index, {
                          locationIds: group.locationIds.filter((x) => x !== id),
                        })
                      }
                    />
                  ))}
                </div>
              )}

              <strong>Wolontariusze</strong>
              {group.volunteerIds.length === 0 ? (
                <p style={{ color: "#999", margin: "0.25rem 0 0" }}>
                  Brak wolontariuszy — wybierz z puli po lewej.
                </p>
              ) : (
                <div
                  style={{ display: "flex", flexWrap: "wrap", gap: "0.4rem", margin: "0.5rem 0 0" }}
                >
                  {group.volunteerIds.map((id) => (
                    <MemberChip
                      key={id}
                      volunteer={volunteersById.get(id)}
                      isDriver={rosterDriverIds.includes(id)}
                      onRemove={() =>
                        updateGroup(index, {
                          volunteerIds: group.volunteerIds.filter((x) => x !== id),
                        })
                      }
                    />
                  ))}
                </div>
              )}

              <strong style={{ display: "block", marginTop: "1.15rem" }}>
                Informacje dla grupy
              </strong>
              <NoteField
                value={group.groupNote}
                onChange={(value) => updateGroup(index, { groupNote: value })}
                placeholder="Dodatkowe informacje dla całej grupy…"
              />
            </section>
          );
        })}

        <button
          type="button"
          className="btn btn-secondary"
          onClick={() => {
            setGroups((prev) => [
              ...prev,
              { locationIds: [], volunteerIds: [], notes: {}, groupNote: "" },
            ]);
            setActiveGroup(groups.length);
          }}
        >
          + Dodaj grupę
        </button>
      </div>
    </div>
  );
}

function LocationCard({
  loc,
  onClick,
  onRemove,
  selected,
  note,
  onNoteChange,
}: {
  loc?: LocationOption;
  onClick?: () => void;
  onRemove?: () => void;
  selected?: boolean;
  note?: string;
  onNoteChange?: (value: string) => void;
}) {
  return (
    <div
      onClick={onClick}
      role={onClick ? "button" : undefined}
      aria-label={onClick ? loc?.name : undefined}
      style={{
        ...locationCard,
        cursor: onClick ? "pointer" : "default",
        borderColor: selected ? "#27ae60" : "#e0e0e0",
        background: selected ? "#f3fbf5" : "#fafafa",
      }}
    >
      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "flex-start",
          gap: "0.5rem",
        }}
      >
        <strong>{loc?.name ?? "?"}</strong>
        <span style={{ display: "flex", alignItems: "center", gap: "0.3rem" }}>
          <RecencyBadge rank={loc?.recent_rank ?? null} />
          {onRemove && (
            <button
              type="button"
              style={removeChip}
              title="Usuń"
              aria-label={`Usuń: ${loc?.name ?? ""}`}
              onClick={(e) => {
                e.stopPropagation();
                onRemove();
              }}
            >
              ✕
            </button>
          )}
        </span>
      </div>
      <div style={{ color: "#888", fontSize: "0.75rem" }}>
        {locationTypeLabel(loc?.location_type)}
      </div>
      {loc && (loc.people.length > 0 || loc.person_count > 0) && (
        <div style={{ color: "#555", fontSize: "0.8rem", marginTop: "0.25rem" }}>
          👤 {loc.people.length > 0 ? loc.people.map((p) => p.name).join(", ") : loc.person_count}
        </div>
      )}
      {loc && loc.animals.length > 0 && (
        <div style={{ color: "#555", fontSize: "0.8rem", marginTop: "0.15rem" }}>
          🐾 {loc.animals.map((a) => `${a.name} (${speciesLabel(a.species)})`).join(", ")}
        </div>
      )}
      {onNoteChange && <NoteField value={note ?? ""} onChange={onNoteChange} />}
    </div>
  );
}

// Collapsed "+ dodatkowe informacje" link → textarea (opens on click, collapses
// on blur when empty) → clamped text when filled. Shared by location and group notes.
function NoteField({
  value,
  onChange,
  placeholder = "Dodatkowe informacje…",
}: {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
}) {
  const [open, setOpen] = useState(false);

  if (open) {
    return (
      <textarea
        className="form-control"
        placeholder={placeholder}
        value={value}
        autoFocus
        rows={2}
        onClick={(e) => e.stopPropagation()}
        onBlur={() => setOpen(false)}
        onChange={(e) => onChange(e.target.value)}
        style={{ marginTop: "0.4rem", fontSize: "0.8rem" }}
      />
    );
  }
  const openNote = (e: React.MouseEvent) => {
    e.stopPropagation();
    setOpen(true);
  };

  if (value !== "") {
    return (
      <div
        role="button"
        aria-label={placeholder}
        title={value}
        onClick={openNote}
        style={clampedNote}
      >
        📝 {value}
      </div>
    );
  }
  return (
    <div
      role="button"
      aria-label={placeholder}
      onClick={openNote}
      style={{ color: "#2c6cb0", fontSize: "0.75rem", marginTop: "0.25rem", cursor: "pointer" }}
    >
      + dodatkowe informacje
    </div>
  );
}

function MemberChip({
  volunteer,
  isDriver,
  onToggleDriver,
  onRemove,
}: {
  volunteer?: Option;
  isDriver: boolean;
  onToggleDriver?: () => void;
  onRemove: () => void;
}) {
  const name = volunteer?.name ?? "?";
  return (
    <span style={memberChip}>
      <span aria-hidden="true">{personIcon(volunteer?.gender)}</span>
      <span>{name}</span>
      {onToggleDriver ? (
        <button
          type="button"
          aria-label={`Kierowca: ${name}`}
          title={isDriver ? "Kierowca — kliknij, by cofnąć" : "Oznacz jako kierowcę"}
          onClick={onToggleDriver}
          style={{
            ...driverToggle,
            filter: isDriver ? "none" : "grayscale(1)",
            opacity: isDriver ? 1 : 0.4,
          }}
        >
          🚗
        </button>
      ) : (
        isDriver && <span aria-hidden="true">🚗</span>
      )}
      <button type="button" aria-label={`Usuń: ${name}`} onClick={onRemove} style={removeChip}>
        ✕
      </button>
    </span>
  );
}

function RecencyBadge({ rank }: { rank: number | null }) {
  if (rank === 0) return <span style={{ ...badge, background: "#27ae60" }}>ostatni</span>;
  if (rank === 1) return <span style={{ ...badge, background: "#f39c12" }}>2 temu</span>;
  return null;
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

function peopleWord(n: number): string {
  if (n === 1) return "osoba";
  const lastTwo = n % 100;
  const last = n % 10;
  if (last >= 2 && last <= 4 && !(lastTwo >= 12 && lastTwo <= 14)) return "osoby";
  return "osób";
}

function personIcon(gender?: string | null): string {
  if (gender === "female") return "👩";
  if (gender === "male") return "👨";
  if (gender === "non_binary") return "🧑";
  return "👤";
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

const poolPanel: React.CSSProperties = { ...card, width: "100%", marginBottom: 0 };

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

const checkboxRow: React.CSSProperties = {
  display: "flex",
  alignItems: "center",
  gap: "0.4rem",
  margin: "0 0 0.5rem",
  fontSize: "0.85rem",
  color: "#555",
};

const cardGrid: React.CSSProperties = {
  display: "flex",
  flexWrap: "wrap",
  gap: "0.6rem",
};

const clampedNote: React.CSSProperties = {
  marginTop: "0.25rem",
  fontSize: "0.8rem",
  color: "#555",
  cursor: "pointer",
  display: "-webkit-box",
  WebkitLineClamp: 2,
  WebkitBoxOrient: "vertical",
  overflow: "hidden",
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
