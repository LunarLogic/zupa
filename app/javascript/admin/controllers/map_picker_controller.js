import { Controller } from "@hotwired/stimulus";
import { setOptions, importLibrary } from "@googlemaps/js-api-loader";

export default class extends Controller {
  static targets = ["map", "groups", "list"];
  static values = {
    locations: Array,
    groups: Array,
    palette: Array,
    apiKey: String,
    saveUrl: String,
    skipMap: Boolean,
  };

  async connect() {
    this.state = {
      groups: JSON.parse(JSON.stringify(this.groupsValue || [])),
      activeGroupIdx: 0,
    };

    if (this.state.groups.length === 0) {
      this.state.groups.push(this.buildGroup(0));
    }

    this.renderGroups();

    if (this.skipMapValue) {
      this.renderList();
      return;
    }

    setOptions({ key: this.apiKeyValue, v: "weekly" });
    const [{ Map }, { Marker }] = await Promise.all([
      importLibrary("maps"),
      importLibrary("marker"),
    ]);
    this.MapCtor = Map;
    this.MarkerCtor = Marker;
    this.initMap();
    this.renderMarkers();
  }

  renderList() {
    this.listTarget.innerHTML = "";
    this.locationsValue.forEach((loc) => {
      const btn = document.createElement("button");
      btn.type = "button";
      btn.className = "map-picker__list-item";
      btn.dataset.locationId = loc.id;

      const dot = document.createElement("span");
      dot.className = "map-picker__list-dot";
      dot.style.background = this.recencyColor(loc);
      btn.appendChild(dot);
      btn.appendChild(document.createTextNode(loc.name));

      btn.addEventListener("click", () => this.togglePin(loc.id));
      this.listTarget.appendChild(btn);
    });
    this.refreshListItems();
  }

  refreshListItems() {
    if (!this.hasListTarget) return;
    this.listTarget.querySelectorAll(".map-picker__list-item").forEach((btn) => {
      const id = Number(btn.dataset.locationId);
      const owningIdx = this.state.groups.findIndex((g) => g.location_ids.includes(id));
      if (owningIdx >= 0) {
        const color = this.paletteValue[owningIdx % this.paletteValue.length];
        btn.style.background = color;
        btn.style.color = "#fff";
        btn.style.borderColor = color;
      } else {
        btn.style.background = "";
        btn.style.color = "";
        btn.style.borderColor = "";
      }
    });
  }

  initMap() {
    this.map = new this.MapCtor(this.mapTarget, {
      center: KRAKOW_CENTER,
      zoom: 11,
      streetViewControl: false,
      mapTypeControl: false,
      clickableIcons: false,
      styles: MAP_STYLES,
    });
    this.map.fitBounds(KRAKOW_BOUNDS);
  }

  renderMarkers() {
    this.markers = {};
    this.locationsValue.forEach((loc) => {
      const marker = new this.MarkerCtor({
        position: { lat: loc.lat, lng: loc.lng },
        map: this.map,
        title: loc.name,
        icon: this.markerIcon(loc),
      });
      marker.addListener("click", () => this.togglePin(loc.id));
      this.markers[loc.id] = { marker, location: loc };
    });
    this.refreshMarkerIcons();
  }

  markerIcon(loc, groupColor = null) {
    const recency = this.recencyColor(loc);
    const ring = groupColor
      ? `<circle cx='20' cy='20' r='15' fill='${pastelize(groupColor, 0.75)}' stroke='${groupColor}' stroke-width='3'/>`
      : `<circle cx='20' cy='20' r='13' fill='rgba(255,255,255,0.85)' stroke='#bbb' stroke-width='1.5'/>`;
    const svg = `<svg xmlns='http://www.w3.org/2000/svg' width='40' height='40' viewBox='0 0 40 40'>
      ${ring}
      <line x1='16' y1='11' x2='16' y2='29' stroke='#2c2c2c' stroke-width='1.6' stroke-linecap='round'/>
      <path d='M 16 12 L 27 15 L 16 18 Z' fill='${recency}' stroke='#2c2c2c' stroke-width='0.8' stroke-linejoin='round'/>
    </svg>`;
    return {
      url: `data:image/svg+xml;charset=UTF-8,${encodeURIComponent(svg)}`,
      scaledSize: new google.maps.Size(40, 40),
      anchor: new google.maps.Point(20, 20),
    };
  }

  recencyColor(loc) {
    if (loc.recent_rank === 0) return "#27ae60";
    if (loc.recent_rank === 1) return "#f39c12";
    return "#c0392b";
  }

  togglePin(locationId) {
    const active = this.state.groups[this.state.activeGroupIdx];
    if (!active) return;

    const otherGroup = this.state.groups.find(
      (g, i) => i !== this.state.activeGroupIdx && g.location_ids.includes(locationId),
    );
    if (otherGroup) return; // already in another group; must remove there first

    const idx = active.location_ids.indexOf(locationId);
    if (idx === -1) {
      active.location_ids.push(locationId);
      active.locations.push(this.locationsValue.find((l) => l.id === locationId));
    } else {
      active.location_ids.splice(idx, 1);
      active.locations = active.locations.filter((l) => l.id !== locationId);
    }

    this.refreshMarkerIcons();
    this.renderGroups();
    this.persist();
  }

  refreshMarkerIcons() {
    this.refreshListItems();
    if (!this.markers) return;
    Object.values(this.markers).forEach(({ marker, location }) => {
      const owningIdx = this.state.groups.findIndex((g) =>
        g.location_ids.includes(location.id),
      );
      if (owningIdx >= 0) {
        marker.setIcon(this.markerIcon(location, this.paletteValue[owningIdx % this.paletteValue.length]));
      } else {
        marker.setIcon(this.markerIcon(location));
      }
    });
  }

  renderGroups() {
    this.groupsTarget.innerHTML = "";
    this.state.groups.forEach((g, idx) => {
      const color = this.paletteValue[idx % this.paletteValue.length];
      const isActive = idx === this.state.activeGroupIdx;
      const card = document.createElement("div");
      card.className = `map-picker__group ${isActive ? "map-picker__group--active" : ""}`;
      card.style.borderColor = color;
      card.dataset.groupIdx = idx;

      const header = document.createElement("div");
      header.className = "map-picker__group-header";
      header.style.color = color;
      header.innerHTML = `<strong>Grupa ${idx + 1}</strong>`;

      const removeBtn = document.createElement("button");
      removeBtn.type = "button";
      removeBtn.className = "map-picker__group-remove";
      removeBtn.textContent = "✕";
      removeBtn.addEventListener("click", (e) => {
        e.stopPropagation();
        this.removeGroup(idx);
      });
      header.appendChild(removeBtn);

      card.appendChild(header);

      const list = document.createElement("ul");
      list.className = "map-picker__group-locations";
      g.locations.forEach((loc) => {
        const li = document.createElement("li");
        li.textContent = loc.name;
        const x = document.createElement("button");
        x.type = "button";
        x.textContent = "✕";
        x.className = "map-picker__location-remove";
        x.addEventListener("click", (e) => {
          e.stopPropagation();
          this.removeLocation(idx, loc.id);
        });
        li.appendChild(x);
        list.appendChild(li);
      });
      card.appendChild(list);

      card.addEventListener("click", () => this.activateGroup(idx));
      this.groupsTarget.appendChild(card);
    });
  }

  activateGroup(idx) {
    this.state.activeGroupIdx = idx;
    this.renderGroups();
  }

  addGroup() {
    this.state.groups.push(this.buildGroup(this.state.groups.length));
    this.state.activeGroupIdx = this.state.groups.length - 1;
    this.renderGroups();
  }

  removeGroup(idx) {
    if (!confirm("Usunąć grupę?")) return;
    this.state.groups.splice(idx, 1);
    if (this.state.groups.length === 0) {
      this.state.groups.push(this.buildGroup(0));
    }
    this.state.activeGroupIdx = Math.min(this.state.activeGroupIdx, this.state.groups.length - 1);
    this.refreshMarkerIcons();
    this.renderGroups();
    this.persist();
  }

  removeLocation(groupIdx, locationId) {
    const g = this.state.groups[groupIdx];
    g.location_ids = g.location_ids.filter((id) => id !== locationId);
    g.locations = g.locations.filter((l) => l.id !== locationId);
    this.refreshMarkerIcons();
    this.renderGroups();
    this.persist();
  }

  buildGroup(idx) {
    return { id: null, number: idx + 1, location_ids: [], locations: [] };
  }

  persist(advance = false) {
    const form = new FormData();
    this.state.groups.forEach((g, i) => {
      g.location_ids.forEach((id) => {
        form.append(`groups[${i}][location_ids][]`, id);
      });
      if (g.location_ids.length === 0) {
        form.append(`groups[${i}][location_ids][]`, "");
      }
    });
    if (advance) form.append("advance", "1");

    const csrf = document.querySelector('meta[name="csrf-token"]')?.content;
    return fetch(this.saveUrlValue, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": csrf,
        Accept: "text/vnd.turbo-stream.html",
      },
      body: form,
    }).then((r) => r.text());
  }

  advance(event) {
    const hasSomething = this.state.groups.some((g) => g.location_ids.length > 0);
    if (!hasSomething) {
      alert("Dodaj przynajmniej jedną lokację do grupy.");
      return;
    }
    const btn = event?.currentTarget;
    if (btn) {
      btn.disabled = true;
      btn.textContent = "Zapisuję...";
      btn.classList.add("is-saving");
    }
    this.persist(true).then((html) => {
      if (html) Turbo.renderStreamMessage(html);
    });
  }

  back() {
    const showUrl = this.saveUrlValue.replace(/\/locations$/, "");
    const csrf = document.querySelector('meta[name="csrf-token"]')?.content;
    fetch(`${showUrl}?step=basic`, {
      headers: {
        "X-CSRF-Token": csrf,
        Accept: "text/vnd.turbo-stream.html",
      },
    })
      .then((r) => r.text())
      .then((html) => Turbo.renderStreamMessage(html));
  }
}

function avg(arr) {
  if (!arr.length) return 0;
  return arr.reduce((a, b) => a + b, 0) / arr.length;
}

function pastelize(hex, amount = 0.7) {
  const h = hex.replace("#", "");
  const r = parseInt(h.slice(0, 2), 16);
  const g = parseInt(h.slice(2, 4), 16);
  const b = parseInt(h.slice(4, 6), 16);
  const mix = (c) => Math.round(c + (255 - c) * amount);
  return `rgb(${mix(r)},${mix(g)},${mix(b)})`;
}

const KRAKOW_CENTER = { lat: 50.0647, lng: 19.945 };
const KRAKOW_BOUNDS = {
  north: 50.13,
  south: 49.98,
  east: 20.12,
  west: 19.77,
};

const MAP_STYLES = [
  { featureType: "poi", stylers: [{ visibility: "off" }] },
  { featureType: "transit", stylers: [{ visibility: "off" }] },
  { featureType: "road", elementType: "labels", stylers: [{ visibility: "off" }] },
  { featureType: "road.highway", elementType: "labels", stylers: [{ visibility: "on" }] },
  { featureType: "administrative.neighborhood", stylers: [{ visibility: "off" }] },
  { featureType: "administrative.land_parcel", stylers: [{ visibility: "off" }] },
  { featureType: "administrative.locality", elementType: "labels.text", stylers: [{ visibility: "simplified" }] },
  { featureType: "water", elementType: "labels", stylers: [{ visibility: "off" }] },
];
