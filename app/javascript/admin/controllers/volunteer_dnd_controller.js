import { Controller } from "@hotwired/stimulus";
import Sortable from "sortablejs";

export default class extends Controller {
  static targets = ["pool", "zone", "saveBtn", "publishBtn"];
  static values = {
    saveUrl: String,
    publishUrl: String,
    tripId: String,
  };

  connect() {
    this.sortables = [];
    const onChange = () => {
      this.markDirty();
      this.persist();
    };
    const opts = {
      group: "trip-wizard",
      animation: 150,
      forceFallback: true,
      fallbackOnBody: false,
      fallbackTolerance: 3,
      onAdd: onChange,
      onRemove: onChange,
      onUpdate: onChange,
    };

    this.sortables.push(Sortable.create(this.poolTarget, opts));
    this.zoneTargets.forEach((el) => {
      this.sortables.push(Sortable.create(el, opts));
    });
  }

  disconnect() {
    this.sortables.forEach((s) => s.destroy());
    this.sortables = [];
  }

  markDirty() {
    if (this.hasSaveBtnTarget) {
      const btn = this.saveBtnTarget;
      btn.textContent = btn.dataset.saveLabel;
      btn.disabled = false;
      btn.classList.remove("is-saved");
    }
    if (this.hasPublishBtnTarget) {
      this.publishBtnTarget.disabled = true;
    }
  }

  markSaved() {
    if (this.hasSaveBtnTarget) {
      const btn = this.saveBtnTarget;
      btn.textContent = btn.dataset.savedLabel;
      btn.disabled = false;
      btn.classList.add("is-saved");
    }
    if (this.hasPublishBtnTarget) {
      this.publishBtnTarget.disabled = false;
    }
  }

  collectAssignments() {
    const assignments = {};
    this.zoneTargets.forEach((zone) => {
      const groupId = zone.dataset.groupId;
      const role = zone.dataset.role;
      assignments[groupId] ||= { volunteer_ids: [], driver_ids: [] };
      const ids = Array.from(zone.querySelectorAll("[data-volunteer-id]")).map(
        (el) => el.dataset.volunteerId,
      );
      if (role === "driver") {
        assignments[groupId].driver_ids = ids;
      } else {
        assignments[groupId].volunteer_ids = ids;
      }
    });
    return assignments;
  }

  persist() {
    const assignments = this.collectAssignments();
    const form = new FormData();
    Object.entries(assignments).forEach(([gid, data]) => {
      data.volunteer_ids.forEach((id) =>
        form.append(`assignments[${gid}][volunteer_ids][]`, id),
      );
      data.driver_ids.forEach((id) =>
        form.append(`assignments[${gid}][driver_ids][]`, id),
      );
      if (data.volunteer_ids.length === 0) {
        form.append(`assignments[${gid}][volunteer_ids][]`, "");
      }
      if (data.driver_ids.length === 0) {
        form.append(`assignments[${gid}][driver_ids][]`, "");
      }
    });

    const csrf = document.querySelector('meta[name="csrf-token"]')?.content;
    return fetch(this.saveUrlValue, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": csrf,
        Accept: "text/vnd.turbo-stream.html",
      },
      body: form,
    }).then((r) => {
      if (r.status >= 400) {
        return r.text().then((html) => {
          if (html) Turbo.renderStreamMessage(html);
          return null;
        });
      }
      return r;
    });
  }

  save(event) {
    const btn = event?.currentTarget;
    if (btn) {
      btn.disabled = true;
      btn.textContent = "…";
    }
    this.persist().then((r) => {
      if (r && r.status < 400) {
        this.markSaved();
      } else if (btn) {
        btn.disabled = false;
        btn.textContent = btn.dataset.saveLabel;
      }
    });
  }

  publish(event) {
    if (!confirm("Opublikować wyjazd?")) return;
    const btn = event?.currentTarget;
    if (btn) {
      btn.disabled = true;
      btn.textContent = "Zapisuję...";
      btn.classList.add("is-saving");
    }
    const csrf = document.querySelector('meta[name="csrf-token"]')?.content;
    fetch(this.publishUrlValue, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": csrf,
        Accept: "text/vnd.turbo-stream.html",
      },
    })
      .then((r) => r.text())
      .then((html) => {
        if (html) Turbo.renderStreamMessage(html);
      });
  }

  back() {
    const showUrl = this.saveUrlValue.replace(/\/volunteers$/, "");
    const csrf = document.querySelector('meta[name="csrf-token"]')?.content;
    fetch(`${showUrl}?step=locations`, {
      headers: {
        "X-CSRF-Token": csrf,
        Accept: "text/vnd.turbo-stream.html",
      },
    })
      .then((r) => r.text())
      .then((html) => Turbo.renderStreamMessage(html));
  }
}
