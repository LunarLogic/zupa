import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "groupsContainer",
    "groupTemplate",
    "destinationTemplate",
    "group",
    "destinationsContainer",
    "destination",
    "destinationLocationId",
    "destinationLabel",
    "destinationDestroy",
    "groupDestroy",
    "locationSelect",
  ];

  addGroup(event) {
    event.preventDefault();
    const index = Date.now();
    const html = this.groupTemplateTarget.innerHTML.replace(
      /__GROUP_INDEX__/g,
      index.toString(),
    );
    this.groupsContainerTarget.insertAdjacentHTML("beforeend", html);
  }

  removeGroup(event) {
    event.preventDefault();
    const groupEl = event.target.closest("[data-trip-form-target='group']");
    if (!groupEl) return;
    const idField = groupEl.querySelector("input[name$='[id]']");
    if (idField) {
      const destroyField = groupEl.querySelector(
        "input[name$='[_destroy]'][data-trip-form-target='groupDestroy']",
      );
      if (destroyField) destroyField.value = "1";
      groupEl.style.display = "none";
    } else {
      groupEl.remove();
    }
  }

  syncDestinations(event) {
    const select = event.currentTarget;
    const groupEl = select.closest("[data-trip-form-target='group']");
    if (!groupEl) return;
    const container = groupEl.querySelector(
      "[data-trip-form-target='destinationsContainer']",
    );
    const selectedIds = Array.from(select.selectedOptions).map((o) => o.value);
    const selectedNames = new Map(
      Array.from(select.selectedOptions).map((o) => [o.value, o.text]),
    );

    const existingDests = Array.from(
      container.querySelectorAll("[data-trip-form-target='destination']"),
    );

    existingDests.forEach((dest) => {
      const locId = dest.dataset.locationId;
      const destroyField = dest.querySelector(
        "input[data-trip-form-target='destinationDestroy']",
      );
      const idField = dest.querySelector("input[name$='[id]']");
      if (selectedIds.includes(locId)) {
        if (destroyField) destroyField.value = "0";
        dest.style.display = "";
      } else if (idField) {
        if (destroyField) destroyField.value = "1";
        dest.style.display = "none";
      } else {
        dest.remove();
      }
    });

    const visibleLocIds = Array.from(
      container.querySelectorAll("[data-trip-form-target='destination']"),
    )
      .filter((d) => d.style.display !== "none")
      .map((d) => d.dataset.locationId);

    selectedIds.forEach((locId) => {
      if (visibleLocIds.includes(locId)) return;
      const existing = Array.from(
        container.querySelectorAll(
          `[data-trip-form-target='destination'][data-location-id='${locId}']`,
        ),
      ).find((d) => d.querySelector("input[name$='[id]']"));
      if (existing) {
        const destroyField = existing.querySelector(
          "input[data-trip-form-target='destinationDestroy']",
        );
        if (destroyField) destroyField.value = "0";
        existing.style.display = "";
        return;
      }
      const groupInput =
        groupEl.querySelector("input[name*='[groups_attributes]'], select[name*='[groups_attributes]']");
      const groupIndexMatch = groupInput
        ? groupInput.name.match(/\[groups_attributes\]\[([^\]]+)\]/)
        : null;
      const groupIndex = groupIndexMatch ? groupIndexMatch[1] : "0";
      const destIndex = Date.now() + parseInt(locId, 10);
      const html = this.destinationTemplateTarget.innerHTML
        .replace(/__GROUP_INDEX__/g, groupIndex)
        .replace(/__DEST_INDEX__/g, destIndex.toString());
      container.insertAdjacentHTML("beforeend", html);
      const newDest = container.lastElementChild;
      newDest.dataset.locationId = locId;
      const locInput = newDest.querySelector(
        "input[data-trip-form-target='destinationLocationId']",
      );
      if (locInput) locInput.value = locId;
      const label = newDest.querySelector(
        "[data-trip-form-target='destinationLabel']",
      );
      if (label) label.textContent = selectedNames.get(locId) || "";
    });
  }
}
